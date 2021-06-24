import { Await, util } from "../../util";

export interface AuthClient {
    id: string;
}

export interface TokenInfo {
    access_token: string;
    token_type: string;
    expires_in: number;
}

export class Auth {
    baseURL = "https://anilist.co/api/v2";

    client: AuthClient;
    private _token?: TokenInfo;
    private _pkce?: Await<ReturnType<typeof util.generatePkceChallenge>>;

    constructor(client: AuthClient) {
        this.client = client;
    }

    setToken(token: TokenInfo | null) {
        if (!token) delete this._token;
        else this._token = token;
    }

    async getOauthURL() {
        if (!this._pkce) this._pkce = await util.generatePkceChallenge();
        return encodeURI(
            `${this.baseURL}/oauth/authorize?client_id=${this.client.id}&response_type=token`
        );
    }

    isValidToken() {
        return !!this._token && this._token.expires_in > Date.now();
    }

    get token() {
        return this._token;
    }

    async authorize(token: TokenInfo) {
        token.expires_in = Date.now() + token.expires_in * 1000;
        this._token = token;
    }
}
