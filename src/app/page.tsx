import Link from "next/link";
import { ArrowLeft, ArrowLeftRight, BadgeCheck, CarFront, ChevronLeft, Grid2X2, Heart, Laptop, MapPin, Plus, Search, ShieldCheck, Shirt, Sofa, Sparkles, Tag, Wrench } from "lucide-react";

const categories = [
  { name: "إلكترونيات", detail: "هواتف وحواسيب", icon: Laptop },
  { name: "سيارات ونقل", detail: "سيارات ودراجات", icon: CarFront },
  { name: "المنزل والأثاث", detail: "أثاث وأجهزة", icon: Sofa },
  { name: "ملابس وأزياء", detail: "ملابس وإكسسوارات", icon: Shirt },
  { name: "أدوات ومعدات", detail: "معدات وأدوات", icon: Wrench },
  { name: "متنوعات", detail: "كل ما تبحث عنه", icon: Grid2X2 }
];

const demoProducts = [
  { title: "هاتف ذكي بحالة ممتازة", price: "35,000 دج", place: "الجزائر العاصمة", tag: "للبيع", icon: "📱", tone: "mint" },
  { title: "حاسوب محمول", price: "65,000 دج", place: "وهران", tag: "بيع أو تبادل", icon: "💻", tone: "blue" },
  { title: "دراجة هوائية", price: "18,000 دج", place: "قسنطينة", tag: "للتبادل", icon: "🚲", tone: "peach" },
  { title: "طاولة خشبية", price: "12,500 دج", place: "سطيف", tag: "للبيع", icon: "🪑", tone: "lilac" }
];

export default function HomePage() {
  return (
    <main>
      <div className="top-strip"><span><Sparkles size={14} /> سوقك الجزائري الجديد للبيع والشراء والتبادل</span><span>من الجزائر، لكل الجزائر</span></div>
      <header className="site-header container">
        <Link className="brand" href="/" aria-label="BADDEL الصفحة الرئيسية"><span className="brand-mark"><ArrowLeftRight size={23} /></span><span>BADDEL<small>بَــــدّل</small></span></Link>
        <nav className="main-nav"><a href="#categories">التصنيفات</a><a href="#latest">أحدث الإعلانات</a><a href="#how">كيف يعمل؟</a></nav>
        <div className="header-actions"><Link className="login-link" href="/login">تسجيل الدخول</Link><Link className="button button-primary button-small" href="/register"><Plus size={17}/> أضف إعلانك</Link></div>
      </header>

      <section className="hero">
        <div className="hero-glow glow-one"/><div className="hero-glow glow-two"/>
        <div className="container hero-inner">
          <div className="hero-copy">
            <div className="eyebrow"><span className="eyebrow-dot"/> منصتك الجزائرية للتبادل والتجارة</div>
            <h1>الشيء الذي تبحث عنه،<br/><span>قد ينتظرك عند غيرك.</span></h1>
            <p>اكتشف منتجات جديدة ومستعملة، اعرض ما لم تعد تحتاجه، أو بدّله بشيء يناسبك. كل ذلك في مكان واحد.</p>
            <div className="search-panel">
              <div className="search-field"><Search size={20}/><span>ما الذي تبحث عنه اليوم؟</span></div>
              <div className="search-location"><MapPin size={17}/><span>كل الولايات</span><ChevronLeft size={16}/></div>
              <button className="button button-primary search-button"><Search size={18}/> ابحث الآن</button>
            </div>
            <div className="hero-meta"><span><ShieldCheck size={16}/> مجتمع بإعلانات خاضعة للمراجعة</span><span><BadgeCheck size={16}/> ملفات مستخدمين وتقييمات</span></div>
          </div>
          <div className="hero-art" aria-hidden="true">
            <div className="art-orbit orbit-a"/><div className="art-orbit orbit-b"/>
            <div className="swap-card card-main"><div className="swap-card-top"><span className="mini-label">فكرة BADDEL</span><span className="sparkle">✦</span></div><div className="swap-objects"><div className="object object-phone">📱</div><div className="swap-symbol"><ArrowLeftRight size={25}/></div><div className="object object-watch">⌚</div></div><div className="swap-caption"><strong>منتجك له قيمة</strong><span>اكتشف فرص التبادل من حولك</span></div></div>
            <div className="float-chip chip-top"><span>✨</span> بيع بسهولة</div><div className="float-chip chip-bottom"><span>🔄</span> تبادل بذكاء</div>
          </div>
        </div>
      </section>

      <section className="container trust-row"><div><span className="trust-icon"><ShieldCheck size={20}/></span><span><b>تجربة أكثر أمانًا</b><small>أدوات للإبلاغ ومراجعة الإعلانات</small></span></div><div><span className="trust-icon"><MapPin size={20}/></span><span><b>منطقتك أولًا</b><small>اكتشف العروض حسب الولاية</small></span></div><div><span className="trust-icon"><ArrowLeftRight size={20}/></span><span><b>البيع أو التبادل</b><small>اختر الطريقة التي تناسبك</small></span></div></section>

      <section className="section container" id="categories">
        <div className="section-heading"><div><span className="section-kicker">تصفّح بسهولة</span><h2>اكتشف حسب الفئة</h2><p>ابدأ من القسم الأقرب لما تبحث عنه.</p></div><a className="text-link" href="#latest">كل التصنيفات <ArrowLeft size={16}/></a></div>
        <div className="category-grid">{categories.map(({name,detail,icon:Icon},i)=><a className="category-card" href="#latest" key={name}><span className={`category-icon category-${i}`}><Icon size={24}/></span><span><b>{name}</b><small>{detail}</small></span><ChevronLeft className="category-arrow" size={17}/></a>)}</div>
      </section>

      <section className="latest-section" id="latest"><div className="container section">
        <div className="section-heading"><div><span className="section-kicker">فرص تستحق الاكتشاف</span><h2>أحدث الإعلانات</h2><p>تعرّف على المنتجات المعروضة في مجتمع BADDEL.</p></div><a className="text-link" href="/search">عرض الكل <ArrowLeft size={16}/></a></div>
        <div className="product-grid">{demoProducts.map((p,i)=><article className="product-card" key={p.title}><div className={`product-visual visual-${p.tone}`}><span className="product-emoji">{p.icon}</span><button className="favorite-button" aria-label="إضافة للمفضلة"><Heart size={18}/></button><span className="product-tag">{p.tag}</span></div><div className="product-info"><div className="product-location"><MapPin size={13}/>{p.place}</div><h3>{p.title}</h3><strong className="product-price">{p.price}</strong><div className="product-footer"><span>إعلان تجريبي للعرض فقط</span><ChevronLeft size={16}/></div></div></article>)}</div>
        <p className="demo-note">تنبيه: المنتجات المعروضة هنا أمثلة تصميمية فقط، وليست إعلانات حقيقية أو بيانات من قاعدة البيانات.</p>
      </div></section>

      <section className="container how-section" id="how"><div className="how-intro"><span className="section-kicker">ببساطة شديدة</span><h2>ثلاث خطوات،<br/>وفرصة جديدة.</h2><p>سواء كنت تبحث عن شيء أو تريد أن تمنح منتجك فرصة جديدة، البداية سهلة.</p><Link className="button button-primary" href="/register">انضم إلى BADDEL <ArrowLeft size={17}/></Link></div><div className="steps"><div className="step"><span className="step-number">01</span><div><h3>أنشئ حسابك</h3><p>جهّز ملفك الشخصي واختر ولايتك.</p></div></div><div className="step"><span className="step-number">02</span><div><h3>اعرض أو اكتشف</h3><p>انشر منتجك أو ابحث بين الإعلانات.</p></div></div><div className="step"><span className="step-number">03</span><div><h3>تواصل واتفق</h3><p>تحدث مع الطرف الآخر واتفقا على التفاصيل بأمان.</p></div></div></div></section>

      <footer className="footer"><div className="container footer-inner"><Link className="brand footer-brand" href="/"><span className="brand-mark"><ArrowLeftRight size={21}/></span><span>BADDEL<small>بَــــدّل</small></span></Link><p>مساحة واحدة لفرص البيع والشراء والتبادل في الجزائر.</p><span className="copyright">© {new Date().getFullYear()} BADDEL. جميع الحقوق محفوظة.</span></div></footer>
    </main>
  );
}
