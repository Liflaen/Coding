from stringovic import parseString

def test_string():
    assert parseString('2019-01-02Brozova') == 'Brozova2019-01-02'