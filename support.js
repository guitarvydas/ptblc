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

var nameIndex = 0;
var nameStack = [];
var nameMap = "ABCDEFGHIJKLMN";

function topName () {
    var n = nameStack.pop ();
    nameStack.push (n);
    return n;
}

exports.resetName = function () {
    nameIndex = 0;
}

exports.pushNewName = function () {
    nameStack.push (nameIndex);
    nameIndex += 1;
    return "";
}

exports.popName = function () {
    nameStack.pop ();
    return "";
}

exports.getName = function (offsetCharString) {
    let offset = parseInt (offsetCharString);
    console.error (offsetCharString);
    console.error (offset);
    console.error (nameStack);
    return String (nameMap[topName () + offset]);
}
