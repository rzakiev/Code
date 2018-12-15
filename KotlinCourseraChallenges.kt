fun isValidIdentifier(s: String): Boolean {
     val nonEmpty = s.count() != 0
    
    if (nonEmpty) {
            val startsWithLetterOrUnderscore = s.first() == '_' || s.first().toLowerCase() in 'a'..'z'
            var consistsOfOnlyLettersDigitsAndUnderscores = true
            for (character in s) {
               	if (!(character.toLowerCase() in 'a'..'z' || character in '0'..'9' || character == '_'))  {
                   	consistsOfOnlyLettersDigitsAndUnderscores = false
               	}
            }
       		return nonEmpty && startsWithLetterOrUnderscore && consistsOfOnlyLettersDigitsAndUnderscores
    } else {
        return false
    }

            
}

fun main(args: Array<String>) {
    println(isValidIdentifier("name"))   // true
    println(isValidIdentifier("_name"))  // true
    println(isValidIdentifier("_12"))    // true
    println(isValidIdentifier(""))       // false
    println(isValidIdentifier("012"))    // false
    println(isValidIdentifier("no$"))    // false
}
