const p = require("path");
const fs = require("fs-extra");
const { rootDir, appI18nDir } = require("./utils");

/**
 * @type {import("phrasey").PhraseyHooksHandler}
 */
const hook = {
    onTranslationsBuildFinished: async ({ phrasey, state, log }) => {
        if (phrasey.options.source !== "build") {
            log.info("Skipping post-build due to non-build source");
            return;
        }
        await createTranslationDart(phrasey, state, log);
    },
};

module.exports = hook;

/**
 *
 * @param {import("phrasey").Phrasey} phrasey
 * @param {import("phrasey").PhraseyState} state
 * @param {import("phrasey").PhraseyLogger} log
 */
async function createTranslationDart(phrasey, state, log) {
    const translations = state.getTranslations();
    const locales = [...translations.translations.keys()];
    /**
     * @type {string[]}
     */
    const staticKeys = [];
    /**
     * @type {string[]}
     */
    const dynamicKeys = [];

    for (const x of state.getSchema().z.keys) {
        const cname = camel(x.name);
        if (x.parameters && x.parameters.length > 0) {
            const params = x.parameters
                .map((x) => `final String ${x}`)
                .join(", ");
            const callArgs = x.parameters.join(", ");
            dynamicKeys.push(
                `    String ${cname}(${params}) => StringUtils.formatPositional(_json['keys']['${x.name}'], <String>[${callArgs}]);`
            );
        } else {
            staticKeys.push(
                `    String ${cname} get => _json['keys']['${x.name}'];`
            );
        }
    }

    const content = `
import 'dart:convert';
import 'package:utilx/locale.dart';
import 'package:utilx/utilx.dart';

part of 'translator.dart';

class Translation {
    const Translation(this._json);

    final Map<dynamic, dynamic> _json;

    String localeDisplayName get => json['locale']['display'];
    String localeNativeName get => json['locale']['native'];
    String localeCode get => json['locale']['code'];
    Locale locale get => Locale(localeDisplayName, localeNativeName, localeCode);

${staticKeys.join("\n")}

${dynamicKeys.join("\n")}

    static const List<String> availableLocales = <String>[${locales
        .map((x) => `'${x}'`)
        .join(", ")}];

    static const String unk = '?';
}
    `;
    const path = p.join(appI18nDir, "translation.g.dart");
    await fs.writeFile(path, content);
    log.success(`Generated "${p.relative(rootDir, path)}".`);
}

/**
 *
 * @param {string} text
 * @returns {string}
 */
function camel(text) {
    return text[0].toLowerCase() + text.substring(1);
}
