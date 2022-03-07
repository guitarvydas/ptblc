exports.convertToOnes = function (n) {
    var result = "";
    while (n > 0) {
	result = result + "1";
	n -= 1;
    }
    return result;
}

exports.trim = function (s) {
    return s.trim ();
}

var nameAsNumber = 64;

exports.newName = function () {
    nameAsNumber += 1;
}

exports.getName = function () {
    return String.fromCharCode (nameAsNumber);
}

exports.getDeBruijnName = function (offset) {
    return String.fromCharCode (nameAsNumber - offset);
}
