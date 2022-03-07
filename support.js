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

var nameAsNumber = 64
var nameStack = [];

function topName () {
    var n = nameStack.pop ();
    nameStack.push (n);
    return n;
}

exports.pushNewName = function () {
    nameAsNumber += 1;
    nameStack.push (nameAsNumber);
    return "";
}

exports.popName = function () {
    nameStack.pop ();
    return "";
}

exports.getName = function (offset) {
    return String.fromCharCode (topName () - offset);
}
