
import os
from random import getrandbits


def getting_file_length(file_name: str):
    """

    :param file_name:
    :return:
    """
    if os.path.isfile(file_name) is False:
        raise FileNotFoundError()
    file_length = 0
    with open(file=file_name) as f:
        f.seek(os.SEEK_END)
        file_length = f.tell()
    return file_length


def setting_file_random_data(file_name: str):
    """

    :param file_name:
    :return:
    """
    file_length = getting_file_length(file_name=file_name)
    generated_random_decimal = getrandbits(file_length * 8)
    with open(file=file_name, mode=os.OWRONLY) as f:
        f.write(generated_random_decimal)


