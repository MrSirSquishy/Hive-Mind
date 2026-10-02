extends Node

signal honey_changed(new_amount: int)

var honey: int = 0:
	set(value):
		honey = max(0,value) #prevents value from becoming negative
		honey_changed.emit(honey)


func add_money(amount: int) -> void:
	if amount > 0:
		honey += amount


func spend_money(amount: int) -> bool:
	if honey >= amount:
		honey -= amount
		return true
	return false
	
func can_afford(amount: int) -> bool:
	return honey >= amount
