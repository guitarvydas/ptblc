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

exports.pushNewVar = function () {
    nameStack.push (nameIndex);
    nameIndex += 1;
    return "?";
}

exports.popVar = function () {
    nameStack.pop ();
    return "";
}

exports.getVar = function (c) {
    let offset = parseInt (c);
    let n = topName ();
    let ix = n - offset;
    // console.error (`offset ${offset}  n ${n}  ix ${ix}  name ${nameMap[ix]}`);
    // console.error (nameStack);
    return nameMap [ix];
}

function topName () {
    var n = nameStack.pop ();
    nameStack.push (n);
    return n;
}

exports.resetNames = function () {
    nameIndex = 0;
}
