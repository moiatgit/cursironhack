import random

# Soldier


class Soldier:
    def __init__(self, health, strength):
        self.health = health
        self.strength = strength

    def attack(self):
        return self.strength

    def receiveDamage(self, damage):
        self.health -= damage


# Viking

class Viking(Soldier):
    def __init__(self, name, health, strength):
        super().__init__(health, strength)
        self.name = name

    def battleCry(self):
        return "Odin Owns You All!"     # Nice song!

    def receiveDamage(self, damage):
        self.health -= damage
        if self.health > 0:
            return f"{self.name} has received {damage} points of damage"
        return f"{self.name} has died in act of combat"

# Saxon

class Saxon(Soldier):
    def __init__(self, health, strength):
        super().__init__(health, strength)

    def receiveDamage(self, damage):
        self.health -= damage
        if self.health > 0:
            return f"A Saxon has received {damage} points of damage"
        return f"A Saxon has died in combat"

# Davicente

class War():
    def __init__(self):
        self.vikingArmy = []
        self.saxonArmy = []

    def addViking(self, viking):
        self.vikingArmy.append(viking)

    def addSaxon(self, saxon):
        self.saxonArmy.append(saxon)

    def vikingAttack(self):
        if not self.vikingArmy or not self.saxonArmy:
            return
        saxon_index = random.randrange(len(self.saxonArmy))
        saxon = self.saxonArmy[saxon_index]
        viking = random.choice(self.vikingArmy)
        result = saxon.receiveDamage(viking.strength)
        if saxon.health <= 0:
            del self.saxonArmy[saxon_index]
        return result


    def saxonAttack(self):
        viking_index = random.randrange(len(self.vikingArmy))
        viking = self.vikingArmy[viking_index]
        saxon = random.choice(self.saxonArmy)
        result = viking.receiveDamage(saxon.strength)
        if viking.health <= 0:
            del self.vikingArmy[viking_index]
        return result


    def showStatus(self):
        if not self.saxonArmy:
            return "Vikings have won the war of the century!"
        if not self.vikingArmy:
            return "Saxons have fought for their lives and survive another day..."
        return "Vikings and Saxons are still in the thick of battle."
#yop
class War2:

    def __init__(self):
        # your code here
        ...

    def addViking(self, Viking):
        # your code here
        ...

    def addSaxon(self, Saxon):
        # your code here
        ...

    def vikingAttack(self):
        # your code here
        ...

    def saxonAttack(self):
        # your code here
        ...

    def showStatus(self):
        # your code here
        ...

