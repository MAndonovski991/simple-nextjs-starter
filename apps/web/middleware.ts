import createMiddleware from "next-intl/middleware";
import { locales, defaultLocale } from "@packages/i18n";

export default createMiddleware({
  locales: Array.from(locales),
  defaultLocale
});

export const config = {
  matcher: ["/", "/(en|mk)/:path*"]
};
