import qs from "qs";
import { http } from "../../api";
import { Await, util } from "../../util";

export interface AuthClient {
    id: string;
    redirect: string;
}

export interface TokenInfo {
    token_type: string;
    expires_in: number;
    access_token: string;
    refresh_token: string;
}

export type MethodReturn =
    | {
          success: true;
      }
    | {
          success: false;
          error: string;
      };

export class Auth {
    baseURL = "https://myanimelist.net/v1";

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
            `${this.baseURL}/oauth2/authorize?response_type=code&client_id=${this.client.id}&code_challenge_method=plain&code_challenge=${this._pkce.code_challenge}&redirect_uri=${this.client.redirect}`
        );
    }

    async getToken(code: string): Promise<MethodReturn> {
        if (!this._pkce) {
            return {
                success: false,
                error: "No PKCE challenge was generated",
            };
        }

        const res = await this.authorize({
            code,
            grant_type: "authorization_code",
            code_verifier: this._pkce.code_challenge, // huh? mal is weird
        });
        if (!res.access_token) {
            return {
                success: false,
                error: "No 'access_token' was received",
            };
        }

        res.expires_in = Date.now() + res.expires_in;
        this.setToken(res);
        return {
            success: true,
        };
    }

    async refreshToken(): Promise<MethodReturn> {
        if (!this._token) {
            return {
                success: false,
                error: "No 'token' was found",
            };
        }

        let res: TokenInfo;
        try {
            res = await this.authorize({
                refresh_token: this._token.refresh_token,
                grant_type: "refresh_token",
            });
        } catch (err: any) {
            return {
                success: false,
                error: err?.message,
            };
        }

        if (!res.access_token) {
            return {
                success: false,
                error: "No 'access_token' was received",
            };
        }

        res.expires_in = Date.now() + res.expires_in;
        this.setToken(res);
        return {
            success: true,
        };
    }

    isValidToken() {
        return !!this._token && this._token.expires_in > Date.now();
    }

    get token() {
        return this._token;
    }

    async authorize(body: Record<string, string>) {
        const client = await http.getClient();
        try {
            const res = await client.post(
                encodeURI(`${this.baseURL}/oauth2/token`),
                qs.stringify({
                    client_id: this.client.id,
                    redirect_uri: this.client.redirect,
                    ...body,
                }),
                {
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded",
                    },
                    responseType: "text",
                }
            );
            return <TokenInfo>JSON.parse(res);
        } catch (err: any) {
            throw err;
        }
    }
}
