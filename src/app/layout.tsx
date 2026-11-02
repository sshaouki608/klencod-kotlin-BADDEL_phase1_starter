import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "BADDEL | بيع، اشترِ، أو بدّل",
  description: "سوق جزائري للبيع والشراء وتبادل المنتجات.",
  applicationName: "BADDEL"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
