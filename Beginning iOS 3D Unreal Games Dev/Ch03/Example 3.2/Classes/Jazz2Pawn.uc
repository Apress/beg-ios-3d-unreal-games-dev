class Jazz2Pawn extends SimplePawn;


var Inventory MainGun;

function AddDefaultInventory()
{	
    MainGun = InvManager.CreateInventory(class'JazzWeapon2');
    MainGun.SetHidden(false);

    Weapon(MainGun).FireOffset = vect(0,0,-70);
}

defaultproperties
{
    InventoryManagerClass=class'WeaponsIM1'
}


