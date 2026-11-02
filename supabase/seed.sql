-- Minimal category seed. Add the official 58 wilayas and communes dataset after verifying it.
insert into public.categories (name_ar, name_fr, slug, icon, sort_order) values
('إلكترونيات', 'Électronique', 'electronics', 'laptop', 1),
('سيارات ونقل', 'Auto et transport', 'auto-transport', 'car', 2),
('المنزل والأثاث', 'Maison et mobilier', 'home-furniture', 'sofa', 3),
('ملابس وأزياء', 'Vêtements et mode', 'fashion', 'shirt', 4),
('أدوات ومعدات', 'Outils et équipements', 'tools-equipment', 'wrench', 5),
('كتب وهوايات', 'Livres et loisirs', 'books-hobbies', 'book-open', 6),
('رياضة', 'Sport', 'sports', 'dumbbell', 7),
('أخرى', 'Autres', 'other', 'grid', 8)
on conflict (slug) do nothing;
