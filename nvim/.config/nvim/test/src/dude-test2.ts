import { dude2 } from "./common";

function withArgs(arg: string, arg2: number, arg3: boolean){}

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
