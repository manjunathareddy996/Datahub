CREATE OR REPLACE FUNCTION BAGIC_PREPROD_CURATED_DB.UTILS.CONVERT_COL_NAME_TO_SNAKE_CASE("INPUT_STRING" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
AS '
    // Step 1: Handle consecutive uppercase letters
    var input_str = INPUT_STRING.charAt(0).toUpperCase() + INPUT_STRING.slice(1);
    var modifiedString = input_str.replace(/([A-Z])/g, ''_$1'');
    modifiedString = modifiedString.replace('' '', ''_'');
 
    // Step 2: Replace single uppercase letters with underscores
    modifiedString = modifiedString.replace(/([A-Z])/g, ''_$1'');
    modifiedString = modifiedString.replace(/_(.)_/g, ''$1'').replace(/(_\\w)(_)(\\w)/g, function(match, p1, p2, p3) {
        return p1 + p3;
    });
 
    // Step 3: Convert the entire string to lowercase
    var snake_case_string = modifiedString.toLowerCase();
    var finalstr = snake_case_string.replace(/__+/g, ''_'').replace(/^_/, '''').replace(/(_\\w)$/g, function(match) {
        return match.replace(''_'', '''');
    });
 
    // Step 4: Remove any leading underscores
    finalstr = finalstr.replace(/^_+/, '''');
 
    // Step 5: Remove prefix "str_" if present
    if (finalstr.startsWith(''str_'')) {
        finalstr = finalstr.substring(4);
    }
 
    return finalstr;
';