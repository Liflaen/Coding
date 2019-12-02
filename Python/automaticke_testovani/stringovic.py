def parseString (inputString):
    return inputString[10:] + inputString[:10]

print('Revert string is:', parseString('2018-01-02Brozova'))