// Deliberately roastable sample, paste this into WebChat to test your
// code-roaster skill. (Every issue here is real and findable.)

var data;

function doStuff(x, flag, flag2, mode) {
  if (flag == true) {
    if (flag2 == true) {
      if (mode == 1) {
        // process the thing
        try {
          data = JSON.parse(x);
        } catch (e) {}
        return data;
      } else if (mode == 2) {
        try {
          data = JSON.parse(x);
        } catch (e) {}
        return data;
      }
    }
  }
  // TODO: remove before launch (added 2023-06-14)
  // console.log("here");
  return doStuff(x, true, true, 1);
}

function getUserName(u) {
  return u.profile.name.first + " " + u.profile.name.last;
}

setTimeout(function () {
  doStuff('{"a":1}', true, true, 86400000);
}, 250);
