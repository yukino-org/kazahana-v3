module.exports.merge2Obj = (one, two) => {
    for (const key in two) {
        if (Object.prototype.hasOwnProperty.call(two, key)) {
            const ele = two[key];
            if (typeof ele === "object") one[key] = merge2Obj(one[key], ele);
            else one[key] = ele;
        }
    }
    return one;
};

module.exports.mergeObj = (res, ...objs) => {
    objs.forEach((obj) => module.exports.merge2Obj(res, obj));
    return res;
};
