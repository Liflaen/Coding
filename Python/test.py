class Kocka:
    def zamnoukej(self):
        print("{}: Mnau!".format(self.jmeno))

    def je_ziva(self):
        if (self.pocetZivotu > 0):
            print("Jsem ziva! Mam {} zivotu!".format(self.pocetZivotu))

    def uber_zivot(self):
        self.pocetZivotu -= 1
        if (self.pocetZivotu == 0):
            print("Zabil si me :(")
        else:
            print("Au! Zbyva mi {}".format(self.pocetZivotu))
    
    def snez(self, jidlo):
        if (jidlo.lower() == "ryba" or jidlo.lower() == "rybu"):
            if (self.pocetZivotu < 9):
                self.pocetZivotu += 1
                print ("Mnam! To je dobrota, mam {} zivotu.".format(self.pocetZivotu))
            else:
                print ("Uz mam plnej zaludek!")
        else:
            print ("To se neda jist!")

#intro
print("Ahoj jsem tvoje kocicka, pojmenuj si me a hraj si se mnou :)")

# input variables
jmenoKocky = input('Jak se budu jmenovat? ')
zivoty = 9
oddelovac = "*******************"

#second Intro
print("Dekuju to je hezke jmeno :)")

# new instance of kocka
novaKocka = Kocka()
novaKocka.jmeno = jmenoKocky
novaKocka.pocetZivotu = zivoty

# functionality
while (novaKocka.pocetZivotu > 0):
    print ("{}\nCo chces abych delala:\n{}\n1/ Zamnoukala\n2/ Jsem ziva?\n3/ Uber zivot.\n4/ Dej najist.\n5/ Konec".format(oddelovac,oddelovac))
    odpoved = int(input("{}\n".format(oddelovac)))
    if (odpoved == 1):
        novaKocka.zamnoukej()
    elif (odpoved == 2):
        novaKocka.je_ziva()
    elif (odpoved == 3):
        novaKocka.uber_zivot()
    elif (odpoved == 4):
        jidlo = input("Co mi das k jidlu? ")
        novaKocka.snez(jidlo)
    else: 
        print ("{}\nKonec hry!".format(oddelovac))
        break