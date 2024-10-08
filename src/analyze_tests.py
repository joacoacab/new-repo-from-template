"""
This module analyzes the output of a test log.

It extracts information about failed tests, syntax errors, and queries made by tests.
It then prints a summary of the test results, including details of the failed tests
and modules that passed without failures.
"""

import argparse
import re


def print_message(message, success=True):
    """
    Print a message to the console in color.

    Args:
    ----
        message (str): The message to be printed.
        success (bool): If True, the message will be printed in green. If False, in red.

    """
    if success:
        # Green
        start_color = "\033[92m"
    else:
        # Red
        start_color = "\033[91m"
    end_color = "\033[0m"  # Resets the color to default
    print(f"{start_color}{message}{end_color}")


# Create the argument parser
parser = argparse.ArgumentParser(description="Analyze the output of a test log.")
parser.add_argument("log", type=str, help="The output of the test log.")

# Parse the command line arguments
args = parser.parse_args()

# Regular expressions to find the relevant data
test_pattern = re.compile(r"odoo.addons.(\w+).tests.(\w+): (FAIL|ERROR): (\w+).(\w+)")
file_pattern = re.compile(r'File "(.*)", line (\d+), in test_\w+')
error_pattern = re.compile(
    r"(\w+Error): (.*)"
)  # New regular expression to capture any type of error

syntax_error = re.compile(r"(\w+ CRITICAL)(.*)")
total_pattern = re.compile(
    r"\w+ odoo.tests.result: (\d+) failed, \d+ error\(s\) of (\d+) tests"
)
query_pattern = re.compile(
    r"(\w+.\w+.\w+.\w+.\w+): \d+.\d+s (\d+) queries"
)  # New regular expression to capture the queries

# Search for the data in the log
failed_tests = test_pattern.findall(args.log)
failed_files = file_pattern.findall(args.log)
errors = error_pattern.findall(args.log)  # Capture any type of error
total_tests = total_pattern.findall(args.log)
queries = query_pattern.findall(args.log)  # Capture the queries
syntax_errors = syntax_error.findall(args.log)

# Create a set of all the modules that appear in the queries
all_modules = set(test.split(".")[0] for test, _ in queries)

# Create a set of the modules that failed
failed_modules = set(module for module, _, _, *_ in failed_tests)

# The modules that did not fail are all the modules minus the ones that failed
no_failures_modules = all_modules - failed_modules

if syntax_errors:
    print_message(
        "\n\033[1mSyntax errors were found in the log. Please check the log for more details.\033[0m\n\nSummary:\n",
        success=False,
    )
    for error in syntax_errors:
        print(f"{error[0]}: {error[1]}")
    print("\n")
    exit(1)

# Print the summary
if total_tests:
    print(f"{total_tests[0][1]} tests were performed.")

if failed_tests:
    print(f"{len(failed_tests)} tests failed:")
    for (
        (module, file, _, test, method, *_),
        (failed_file, line),
        (error_type, error_message),
    ) in zip(failed_tests, failed_files, errors):
        print(f"\nModule: {module}")
        print(f"  - File: {failed_file}")
        print(f"  - Line: {line}")
        print(f"  - Test: {test}")
        print(f"  - Method: {method}")
        print(f"  - Error: {error_type}: {error_message}")
else:
    print_message("No tests failed", success=True)

print(f"\nModules that passed the tests:")
if no_failures_modules:
    for module in no_failures_modules:
        print(f"- {module}")
else:
    print("No modules with successful tests were found.")

print(f"\nQueries made by each test:")
for (test, num_queries) in queries:
    print(f"- {test}: {num_queries} queries")

if len(failed_modules) > 0:
    print_message(
        """
  _____         _         _                        __       _ _          _
 |_   _|__  ___| |_ ___  | |__   __ ___   _____   / _| __ _(_) | ___  __| |
   | |/ _ \/ __| __/ __| | '_ \ / _` \ \ / / _ \ | |_ / _` | | |/ _ \/ _` |
   | |  __/\__ \ |_\__ \ | | | | (_| |\ V /  __/ |  _| (_| | | |  __/ (_| |
   |_|\___||___/\__|___/ |_| |_|\__,_| \_/ \___| |_|  \__,_|_|_|\___|\__,_|
                                                                           """,
        success=False,
    )
    exit(1)
else:
    print_message(
        """
     _    _ _   _            _                                      _
    / \  | | | | |_ ___  ___| |_ ___   _ __   __ _ ___ ___  ___  __| |
   / _ \ | | | | __/ _ \/ __| __/ __| | '_ \ / _` / __/ __|/ _ \/ _` |
  / ___ \| | | | ||  __/\__ \ |_\__ \ | |_) | (_| \__ \__ \  __/ (_| |
 /_/   \_\_|_|  \__\___||___/\__|___/ | .__/ \__,_|___/___/\___|\__,_|
                                      |_|                             """,
        success=True,
    )
    exit(0)
