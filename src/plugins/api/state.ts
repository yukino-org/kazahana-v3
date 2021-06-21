import { Emitter } from "./emitter";
import { util, RecursivePartial } from "../util";

export type StateUpdateHandler<T> = {
    previous: T;
    current: T;
};

export class State<T> extends Emitter<StateUpdateHandler<T>> {
    handlers: StateUpdateHandler<T>[] = [];
    _props: T;

    constructor(props: T) {
        super();

        this._props = props;
    }

    update(value: RecursivePartial<T>) {
        const previous = { ...this._props };
        const current = util.mergeObject(this._props, value);
        this._props = current;
        this.dispatch({
            previous,
            current,
        });
    }

    get props() {
        return { ...this._props };
    }
}

// export default new GlobalConstants();
