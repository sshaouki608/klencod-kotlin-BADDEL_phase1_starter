import Link from "next/link";

export default function RegisterPage() {
  return <main className="auth-shell"><Link href="/" className="auth-brand">← BADDEL</Link><section className="auth-card"><span className="section-kicker">انضم إلى مجتمعنا</span><h1>إنشاء حساب</h1><p>ابدأ البيع والشراء والتبادل في مكان واحد.</p><form><label>الاسم الكامل<input type="text" placeholder="اسمك" required /></label><label>البريد الإلكتروني<input type="email" placeholder="name@example.com" required /></label><label>كلمة المرور<input type="password" placeholder="8 أحرف على الأقل" minLength={8} required /></label><button className="button button-primary" type="button" disabled>سيتم تفعيل التسجيل في المرحلة الثانية</button></form><small>لديك حساب؟ <Link href="/login">سجّل الدخول</Link></small></section></main>;
}
