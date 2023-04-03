export enum Worker {
  HARD_WORKER = "HARD_WORKER",
  SOFT_WORKER = "SOFT_WORKER",
}

export interface Dude {
  name: string;
  age: number;
  working: boolean;
  type: Worker;
}
