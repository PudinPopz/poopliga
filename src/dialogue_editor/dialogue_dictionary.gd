var dictionary = {}	
var test_content = ["CHARACTER","DIALOGUE","CODE"] # Ignore comments and code for now

class DialogueBlock:
	var dialogue = ""
	var character = ""
	var code = "" # Placeholder for when/if salsalang is implemented
	var tail = "" # Can change at runtime for branching dialogue.
	var choices = [] # Allows for player to select different options
	# For editor use only:
	var key = "" # Own key - READ ONLY JESUS FUCKING CHRIST
	var number = NAN # Ignore for now
	var position = Vector2(0,0) 
	
	# UNUSED
	var uses_bbcode = false


# @TODO: Figure out what updating does
func force_update():
	pass	

# Test
func test():
	var block1 = DialogueBlock.new()
	block1.dialogue = "hey"
	
	add(1,block1)

	print(dictionary)
	
	pass
	
func add(key, block):
	# EXCEPTIONS
	# Check if new name already exists
	if dictionary.has(key):
		print("ERROR: ", key, " already exists")
		return
	dictionary[key] = block
	force_update() # This should force an update
	pass

func get_block(key):
	var block = dictionary[key]
	block.key = key # update key so it knows who it is
	force_update() # This should force an update
	return block
	pass

# NOTE: RENAMING KEYS WILL MAKE PRIOR CONNECTIONS INVALID. (at least for now)
func rename_key(key, new_name):
	# EXCEPTIONS
	# Check if new name already exists
	if dictionary.has(new_name):
		print("ERROR: ", new_name, " already exists")
		return
	
	# Keep old value
	var value = dictionary[key]
	# Create new value
	dictionary[new_name] = value
	# Remove old key from dictionary
	dictionary.erase(key)
	# Update block object with new key
	# Directly accessing value would probably be faster but that's scary.
	var block = dictionary[new_name] 
	block.key = new_name
	force_update() # Definitely force an update