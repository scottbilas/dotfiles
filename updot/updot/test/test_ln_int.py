# this file contains high level integration tests for `ln`

import os

import pytest

from testutils import expand
from testutils import links_db # pylint: disable=unused-import
from updot import platform
from updot.links import ln

# pylint: disable=redefined-outer-name, invalid-name


def test__basic_integration_scenario__succeeds(fs, links_db):  # pylint: disable=unused-argument

    # pylint: disable=bad-whitespace

    # arrange


    #|
    # operations
    #|



    # validations

if __name__ == "__main__":
    pytest.main(__file__)
