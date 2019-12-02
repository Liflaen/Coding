def vyber_chybne(zaznamy):
    res = []
    for x in zaznamy:
        rozdelene = x.split()
        if (rozdelene[0].islower() or rozdelene[1].islower()):
            res.append(x)
    return res

def vyber_spravne(zaznamy, chybne_zaznamy):
    return (list(set(zaznamy) - set(chybne_zaznamy)))

def oprav_zaznamy(chybne_zaznamy, spravne_zaznamy):
    res = []
    for x in chybne_zaznamy:
        rozdelene = x.split()
        res_string = []
        for i in range(len(rozdelene)):
            res_string.append(rozdelene[i].capitalize())
        res_string_joined = ' '.join(res_string)
        res.append(res_string_joined)

    res.extend(spravne_zaznamy)
    return res

zaznamy = ["pepa novák", "Jiří Sládek", "Ivo navrátil", "jan Poledník"]
print(zaznamy)

chybne_zaznamy = vyber_chybne(zaznamy)
print(chybne_zaznamy) # → ["pepa novák", "Ivo navrátil", "jan Poledník"]

spravne_zaznamy = vyber_spravne(zaznamy, chybne_zaznamy)
print(spravne_zaznamy) # → ["Jiří Sládek"]

opravene_zaznamy = oprav_zaznamy(chybne_zaznamy, spravne_zaznamy)
print(opravene_zaznamy) # → ["Pepa Novák", "Jiří Sládek", "Ivo Navrátil", "Jan Poledník"]