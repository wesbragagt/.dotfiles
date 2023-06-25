import { dude2 } from "./lib";

export const dude = {
  getChicken: () => console.log("chicken"),
};

const foobar = dude;

export const foo = {
  bar: () => console.log("bar"),
};

export function random() {
  return Math.random();
}

console.log(dude2());
