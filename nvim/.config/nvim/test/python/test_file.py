class Dude:
    def __init__(self, name: str):
        self.name = name

    def greeter(self):
        return f'Hello, {self.name}!'


def test_file():
    dude = Dude(name='John')

    result = dude.greeter()

    assert result == 'Hello, John!'
