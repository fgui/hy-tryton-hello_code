import hy
from trytond.pool import Pool
from . import hello


def register():
    Pool.register(
        hello.Hello,
        hello.Configuration,
        module='hello_code', type_='model')
