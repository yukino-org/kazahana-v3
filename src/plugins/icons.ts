import { library } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import {
    faHome,
    faSearch,
    faExternalLinkAlt,
    faArrowUp,
    faCaretLeft,
    faCaretRight,
    faCaretDown,
    faInfoCircle,
    faExclamationCircle,
    faQuestionCircle,
    faPlay,
} from "@fortawesome/free-solid-svg-icons";
import { faSnowflake } from "@fortawesome/free-regular-svg-icons";

library.add(
    faHome,
    faSearch,
    faSnowflake,
    faExternalLinkAlt,
    faArrowUp,
    faCaretLeft,
    faCaretRight,
    faCaretDown,
    faInfoCircle,
    faExclamationCircle,
    faQuestionCircle,
    faPlay
);

export default FontAwesomeIcon;
