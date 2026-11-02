import Link from "next/link";

export default function LoginPage() {
  return <main className="auth-shell"><Link href="/" className="auth-brand">← BADDEL</Link><section className="auth-card"><span className="section-kicker">مرحبًا بعودتك</span><h1>تسجيل الدخول</h1><p>ادخل إلى حسابك لمتابعة إعلاناتك ومحادثاتك.</p><form><label>البريد الإلكتروني<input type="email" placeholder="name@example.com" required /></label><label>كلمة المرور<input type="password" placeholder="كلمة المرور" required /></label><button className="button button-primary" type="button" disabled>سيتم تفعيل الدخول في المرحلة الثانية</button></form><small>ليس لديك حساب؟ <Link href="/register">أنشئ حسابًا</Link></small></section></main>;
}
