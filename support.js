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

exports.genNewVar = function () {
    return "?";
}

exports.getVar = function () {
    return "?";
}

// function topName () {
//     var n = nameStack.pop ();
//     nameStack.push (n);
//     return n;
// }

// exports.resetName = function () {
//     nameIndex = 0;
// }

// exports.pushNewName = function () {
//     nameStack.push (nameIndex);
//     nameIndex += 1;
//     return "";
// }

// exports.popName = function () {
//     nameStack.pop ();
//     return "";
// }

// exports.getName = function (offsetCharString) {
//     let offset = parseInt (offsetCharString);
//     return String (nameMap[topName () + offset]);
// }
