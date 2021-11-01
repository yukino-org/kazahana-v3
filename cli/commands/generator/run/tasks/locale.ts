import { dirname, join } from "path";
import chalk from "chalk";
import got from "got";
import { Octokit } from "@octokit/rest";
import { ensureDir, readFile, writeFile, lstat } from "fs-extra";
import { config } from "../../../../config";
import { Repos } from "../../../../constants";
import { Logger } from "../../../../logger";

const logger = new Logger("generator:run:locale");

export const localeFile = join(
    config.base,
    "packages/utilx/lib/generated/locale.g.dart"
);

const reservedIdentifiers = ["as", "do", "in", "is"];

export const generateLocales = async () => {
    let previousContent: string | undefined;
    try {
        previousContent = (await readFile(localeFile)).toString();
    } catch (err: any) {
        if (err.code != "ENOENT") {
            throw err;
        }
    }

    const previousSha = previousContent?.match(
        /\/\/ SHA: (\b[0-9a-f]{5,40}\b)/
    )?.[1];
    const previousId = previousContent?.match(
        /\/\/ ID: ([A-Za-z0-9+\/=]+)/
    )?.[1];

    const fileStat = await lstat(__filename);
    const latestId = Buffer.from(
        `${fileStat.ctimeMs}-${fileStat.mtimeMs}`
    ).toString("base64");

    const octokit = new Octokit();
    const {
        data: [{ sha: latestSha }],
    } = await octokit.request("GET /repos/{owner}/{repo}/commits", {
        ...Repos.extensionsStore.repo,
        per_page: 1,
    });

    if (previousSha === latestSha && previousId === latestId) {
        logger.log(`Aborting update due to matching SHA and ID`);
        return;
    }

    const { body } = await got.get(
        Repos.extensionsStore.languagesJson(latestSha),
        {
            responseType: "json",
        }
    );

    const {
        countries,
        languages,
    }: {
        countries: Record<string, string>;
        languages: Record<string, string>;
    } = body as any;

    const content = `
// SHA: ${latestSha}
// ID: ${latestId}
// Generated file. Do not edit.

${getLanguagesClass(languages)}

${getCountriesClass(countries)}
    `.trim();

    await ensureDir(dirname(localeFile));
    await writeFile(localeFile, content);
    logger.log(`Generated ${chalk.cyanBright(localeFile)}`);
};

const getLanguagesClass = (languages: Record<string, string>) => {
    return `
enum LanguageCodes {
${Object.keys(languages)
    .map((x) => `    ${escapeIdentifier(x)}`)
    .join(",\n")}
}
      
extension LanguageCodesUtils on LanguageCodes {
    String get code => name.replaceFirst(RegExp(r'_$'), '');
    String get language => LanguageCodesUtils.codeNameMap[this]!;
}

abstract class LanguageUtils {
    static Map<LanguageCodes, String> codeNameMap =
        <LanguageCodes, String>{
${Object.entries(languages)
    .map(
        ([code, lang]) =>
            `        LanguageCodes.${escapeIdentifier(code)}: '${lang.replace(
                /'/,
                "\\'"
            )}'`
    )
    .join(",\n")}
    };

    static final Map<String, LanguageCodes> nameCodeMap =
        LanguageCodes.values
            .asMap()
            .map(
                (final int k, final LanguageCodes v) =>
                    MapEntry<String, LanguageCodes>(v.name, v),
            )
            .cast<String, LanguageCodes>();
    }
      `.trim();
};

const getCountriesClass = (countries: Record<string, string>) => {
    return `
enum CountryCodes {
${Object.keys(countries)
    .map((x) => `    ${escapeIdentifier(x)}`)
    .join(",\n")}
}
      
extension CountryCodesUtils on CountryCodes {
    String get code => name.replaceFirst(RegExp(r'_$'), '');
    String get language => CountryCodesUtils.codeNameMap[this]!;
}

abstract class CountryUtils {
    static Map<CountryCodes, String> codeNameMap =
        <CountryCodes, String>{
${Object.entries(countries)
    .map(
        ([code, country]) =>
            `        CountryCodes.${escapeIdentifier(code)}: '${country.replace(
                /'/,
                "\\'"
            )}'`
    )
    .join(",\n")}
    };

    static final Map<String, CountryCodes> nameCodeMap =
    CountryCodes.values
            .asMap()
            .map(
                (final int k, final CountryCodes v) =>
                    MapEntry<String, CountryCodes>(v.name, v),
            )
            .cast<String, CountryCodes>();
    }
      `.trim();
};

const escapeIdentifier = (value: string) =>
    reservedIdentifiers.includes(value) ? `${value}_` : value;
