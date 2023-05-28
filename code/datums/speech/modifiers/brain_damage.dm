TYPEINFO(/datum/speech_module/modifier/brain_damage)
	id = "brain_damage"
/datum/speech_module/modifier/brain_damage
	id = "brain_damage"

	process(datum/say_message/message)
		var/mob/speaker = message.speaker
		if(!istype(speaker))
			return message
		else if (speaker.get_brain_damage() >= 60)
			message.content = replacetext(message.content, "is ", "am ")
			message.content = replacetext(message.content, "are ", "am ")
			message.content = replacetext(message.content, "i ", "me ")
			message.content = replacetext(message.content, "have ", "am ")
			message.content = replacetext(message.content, "youre ", "your ")
			message.content = replacetext(message.content, "you're ", "your ")
			message.content = replacetext(message.content, "attack ", "kill ")
			message.content = replacetext(message.content, "hurt", " kill")
			message.content = replacetext(message.content, "acquire ", "get ")
			message.content = replacetext(message.content, "attempt ", "try ")
			message.content = replacetext(message.content, "attention ", "help ")
			message.content = replacetext(message.content, "attempt ", "try ")
			message.content = replacetext(message.content, "grief", "grife")
			message.content = replacetext(message.content, "her ", "she ")
			message.content = replacetext(message.content, "him ", "he ")
			message.content = replacetext(message.content, "heal", "fix")
			message.content = replacetext(message.content, "repair ", "fix")
			message.content = replacetext(message.content, "heal ", "fix")
			message.content = replacetext(message.content, "space", "spess")
			message.content = replacetext(message.content, "clown", "honky man")
			message.content = replacetext(message.content, "cluwne", "bad honky man")
			message.content = replacetext(message.content, "traitor", "bad guy")
			message.content = replacetext(message.content, "spy", "bad guy")
			message.content = replacetext(message.content, "operative", "bad guy")
			message.content = replacetext(message.content, "nukie", "bad guy")
			message.content = replacetext(message.content, "vampire", "bad guy")
			message.content = replacetext(message.content, "wrestler", "bad guy")
			message.content = replacetext(message.content, "alien", "allen")
			message.content = replacetext(message.content, "changeling", "alien")
			message.content = replacetext(message.content, "pain", "hurt")
			message.content = replacetext(message.content, "damage", "hurt")
			message.content = replacetext(message.content, "they", "them")
		return message
