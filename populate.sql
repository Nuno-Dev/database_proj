DROP TABLE category cascade;
DROP TABLE simple_category cascade;
DROP TABLE super_category cascade;
DROP TABLE has_other cascade;
DROP TABLE product cascade;
DROP TABLE has_category cascade;
DROP TABLE ivm cascade;
DROP TABLE retail_point cascade;
DROP TABLE installed_at cascade;
DROP TABLE shelve cascade;
DROP TABLE planogram cascade;
DROP TABLE retailer cascade;
DROP TABLE responsible_for cascade;
DROP TABLE replenish_event cascade;


----------------------------------------
-- Table Creation
----------------------------------------

CREATE TABLE category
    (category_name varchar(80) not null unique, 
    PRIMARY KEY(category_name));

CREATE TABLE simple_category
    (simple_category_name varchar(80) not null, 
    FOREIGN KEY(simple_category_name) REFERENCES category(category_name));

CREATE TABLE super_category
    (super_category_name varchar(80) not null unique, 
    FOREIGN KEY(super_category_name) REFERENCES category(category_name));

CREATE TABLE has_other
    (super_category_name varchar(80) not null,
    category_name varchar(80) not null,
    PRIMARY KEY(category_name),
    FOREIGN KEY(category_name) REFERENCES category(category_name),
    FOREIGN KEY(super_category_name) REFERENCES super_category(super_category_name),
    CHECK (category_name != super_category_name)); -- RI-RE5
    
CREATE TABLE product
    (product_ean bigint not null unique,
    category_name varchar(80) not null,
    product_description varchar(80) not null,
    PRIMARY KEY(product_ean),
    FOREIGN KEY(category_name) REFERENCES category(category_name));

CREATE TABLE has_category
    (product_ean bigint not null,
    category_name varchar(80) not null,
    PRIMARY KEY(product_ean, category_name),
    FOREIGN KEY(product_ean) REFERENCES product(product_ean),
    FOREIGN KEY(category_name) REFERENCES category(category_name));

CREATE TABLE ivm
    (ivm_serial_number integer not null unique,
    ivm_fabricant_number integer not null unique,
    PRIMARY KEY(ivm_serial_number, ivm_fabricant_number));

CREATE TABLE retail_point
    (retail_point_name varchar(80) not null unique,
    retail_point_district varchar(80) not null,
    retail_point_county varchar(80) not null,
    PRIMARY KEY(retail_point_name));

CREATE TABLE installed_at
    (ivm_serial_number integer not null,
    ivm_fabricant_number integer not null,
    retail_point_name varchar(80) not null unique,
    PRIMARY KEY(ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (ivm_serial_number, ivm_fabricant_number) REFERENCES ivm(ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (retail_point_name) REFERENCES retail_point(retail_point_name));

CREATE TABLE shelve
    (shelve_number integer not null unique,
    ivm_serial_number integer not null,
    ivm_fabricant_number integer not null,
    shelve_height integer not null,
    category_name varchar(80) not null,
    PRIMARY KEY(shelve_number, ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (ivm_serial_number, ivm_fabricant_number) REFERENCES ivm(ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (category_name) REFERENCES category(category_name));

CREATE TABLE planogram
    (product_ean bigint not null,
    shelve_number integer not null unique,
    ivm_serial_number integer not null,
    ivm_fabricant_number integer not null,
    planogram_faces integer not null,
    planogram_units integer not null,
    planogram_loc varchar(80) not null, 
    PRIMARY KEY(product_ean, shelve_number, ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (product_ean) REFERENCES product(product_ean),
    FOREIGN KEY (shelve_number) REFERENCES shelve(shelve_number),
    FOREIGN KEY (ivm_serial_number, ivm_fabricant_number) REFERENCES ivm(ivm_serial_number, ivm_fabricant_number));

CREATE TABLE retailer
    (retailer_tin integer not null unique,
    retailer_name varchar(80) not null unique,
    PRIMARY KEY(retailer_tin));

CREATE TABLE responsible_for
    (ivm_serial_number integer not null,
    ivm_fabricant_number integer not null,
    category_name varchar(80) not null unique,
    retailer_tin integer not null,
    PRIMARY KEY(ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY (category_name) REFERENCES category(category_name),
    FOREIGN KEY (retailer_tin) REFERENCES retailer(retailer_tin));
    
CREATE TABLE replenish_event
    (product_ean bigint not null,
    shelve_number integer not null,
    ivm_serial_number integer not null,
    ivm_fabricant_number integer not null,
    replenish_event_instant varchar(80) not null,
    replenish_event_units integer not null,
    retailer_tin integer not null,
    PRIMARY KEY(product_ean, shelve_number, ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY(product_ean) REFERENCES product(product_ean),
    FOREIGN KEY(shelve_number) REFERENCES shelve(shelve_number),
    FOREIGN KEY (ivm_serial_number, ivm_fabricant_number) REFERENCES ivm(ivm_serial_number, ivm_fabricant_number),
    FOREIGN KEY(retailer_tin) REFERENCES retailer(retailer_tin));

----------------------------------------
-- Populate Relations 
----------------------------------------

insert into ivm values (12313, 51247);
insert into ivm values (53234, 62324);
insert into ivm values (92834, 85723);
insert into ivm values (34234, 42163);
insert into ivm values (34817, 54335);
insert into ivm values (64363, 14212);
insert into ivm values (12235, 23432);
insert into ivm values (62334, 62423);
insert into ivm values (94534, 52355);
insert into ivm values (12352, 75673);
insert into ivm values (64335, 64373);
insert into ivm values (23142, 12462);
insert into ivm values (78554, 64384);
insert into ivm values (32632, 98454);
insert into ivm values (63324, 84587);

insert into category values ('book');
insert into category values ('food');
insert into category values ('clothes');
insert into category values ('box');
insert into category values ('medication');
insert into category values ('method of transportation');
insert into category values ('paper');
insert into category values ('machine');
insert into category values ('housing');
insert into category values ('painting');
insert into category values ('sports');
insert into category values ('running');
insert into category values ('golf');
insert into category values ('IT');
insert into category values ('swimming');
insert into category values ('football');
insert into category values ('basketball');
insert into category values ('videogame');
insert into category values ('sub-21 football');
insert into category values ('NBA');
insert into category values ('European Basketball League');
insert into category values ('Butterfly');

insert into simple_category values ('running');
insert into simple_category values ('golf');
insert into simple_category values ('sub-21 football');
insert into simple_category values ('NBA');
insert into simple_category values ('European Basketball League');
insert into simple_category values ('Butterfly');

insert into super_category values ('sports');
insert into super_category values ('football');
insert into super_category values ('basketball');
insert into super_category values ('swimming');

insert into has_other values ('sports','running');
insert into has_other values ('sports','golf');
insert into has_other values ('sports','swimming');
insert into has_other values ('sports','basketball');
insert into has_other values ('sports','football');
insert into has_other values ('football','sub-21 football');
insert into has_other values ('basketball','NBA');
insert into has_other values ('basketball','European Basketball League');
insert into has_other values ('swimming','Butterfly');

insert into product values (5712545271821 , 'food', 'chocolate');
insert into product values (7097988315759 , 'food', 'pizza');
insert into product values (2046110652679 , 'food', 'hamburguer');
insert into product values (1998696784414 , 'food', 'sushi');
insert into product values (5415096718779 , 'food', 'salad');
insert into product values (2351180780876 , 'swimming', 'swimming goggles');
insert into product values (6254241777551 , 'running', 'running shoes');
insert into product values (8434524837935 , 'basketball', 'basketball ball');
insert into product values (7142352352356 , 'golf', 'golf ball');
insert into product values (8078872282643 , 'football', 'football ball');
insert into product values (6099525434848 , 'medication', 'xanax');
insert into product values (2192564612616 , 'medication', 'ibuprofen');
insert into product values (6631749930080 , 'clothes', 'shirt');
insert into product values (9144706592862 , 'clothes', 'trousers');
insert into product values (1216097579727 , 'clothes', 'black hat');
insert into product values (4902016227380 , 'IT', 'PS5');
insert into product values (4038217028032 , 'IT', 'xbox');
insert into product values (7446759636332 , 'IT', 'nintendo switch');
insert into product values (3961290048137 , 'videogame', 'god of war');
insert into product values (5055638270225 , 'videogame', 'diablo 5');
insert into product values (6485954658361 , 'videogame', 'far cry 6');
insert into product values (3411277813035 , 'videogame', 'dark souls 2');
insert into product values (2818058980622 , 'videogame', 'elden ring');
insert into product values (3854887738248 , 'videogame', 'fifa manager');

insert into has_category values (5712545271821 , 'food');
insert into has_category values (7097988315759 , 'food');
insert into has_category values (2046110652679 , 'food');
insert into has_category values (1998696784414 , 'food');
insert into has_category values (5415096718779 , 'food');
insert into has_category values (2351180780876 , 'swimming');
insert into has_category values (6254241777551 , 'running');
insert into has_category values (8434524837935 , 'basketball');
insert into has_category values (7142352352356 , 'golf');
insert into has_category values (8078872282643 , 'football');
insert into has_category values (6099525434848 , 'medication');
insert into has_category values (2192564612616 , 'medication');
insert into has_category values (6631749930080 , 'clothes');
insert into has_category values (9144706592862 , 'clothes');
insert into has_category values (1216097579727 , 'clothes');
insert into has_category values (4902016227380 , 'IT');
insert into has_category values (4038217028032 , 'IT');
insert into has_category values (7446759636332 , 'IT');
insert into has_category values (3961290048137 , 'videogame');
insert into has_category values (5055638270225 , 'videogame');
insert into has_category values (6485954658361 , 'videogame');
insert into has_category values (3411277813035 , 'videogame');
insert into has_category values (2818058980622 , 'videogame');
insert into has_category values (3854887738248 , 'videogame');

insert into retail_point values ('galp', 'lisbon', 'sintra');
insert into retail_point values ('continente', 'lisbon', 'alges');
insert into retail_point values ('amazon', 'setubal', 'palmela');
insert into retail_point values ('pingo doce', 'setubal', 'montijo');
insert into retail_point values ('intermarche', 'setubal', 'moita');
insert into retail_point values ('bp', 'aveiro', 'agueda');
insert into retail_point values ('best buy', 'aveiro', 'arouca');

insert into installed_at values (92834, 85723, 'galp');
insert into installed_at values (94534, 52355, 'continente');
insert into installed_at values (23142, 12462, 'pingo doce');
insert into installed_at values (63324, 84587, 'best buy');
insert into installed_at values (12313, 51247, 'intermarche');

insert into shelve values (42182, 12313, 51247, 10, 'food');
insert into shelve values (51232, 34817, 54335, 6, 'videogame');
insert into shelve values (65423, 12235, 23432, 12, 'sports');
insert into shelve values (73453, 64363, 14212, 8, 'food');
insert into shelve values (48262, 94534, 52355, 5, 'clothes');
insert into shelve values (64234, 12352, 75673, 32, 'IT');
insert into shelve values (12363, 63324, 84587, 6, 'medication');
insert into shelve values (73123, 64335, 64373, 17, 'food');
insert into shelve values (93274, 32632, 98454, 23, 'videogame');

insert into planogram values (5712545271821, 42182, 12313, 51247, 12, 25, 'loc1'); --food
insert into planogram values (4902016227380, 73123, 64335, 64373, 7, 18, 'loc2'); --IT
insert into planogram values (3961290048137, 51232, 34817, 54335, 18, 31, 'loc3'); --videogame
insert into planogram values (9144706592862, 48262, 94534, 52355, 10, 13, 'loc4'); --clothes

insert into retailer values (1238, 'Amazon');
insert into retailer values (3152, 'Costco');
insert into retailer values (9823, 'Wallmart');
insert into retailer values (1518, 'Kroger');
insert into retailer values (4821, 'Aldi');
insert into retailer values (4371, 'Tesco');
insert into retailer values (9172, 'Edeka');

insert into responsible_for values (92834, 85723, 'videogame', 1238);
insert into responsible_for values (34234, 42163, 'food', 3152);
insert into responsible_for values (64363, 14212, 'sports', 9823);
insert into responsible_for values (12235, 23432, 'clothes', 1518);
insert into responsible_for values (23142, 12462, 'medication', 4821);
insert into responsible_for values (12352, 75673, 'IT', 4371);
insert into responsible_for values (63324, 84587, 'running', 9172);

insert into replenish_event values (5712545271821, 42182, 12313, 51247, '2022-12-18 12:32:05', 5, 3152);
insert into replenish_event values (5712545271821, 73123, 12313, 51247, '2022-12-20 17:59:17', 13, 3152);
insert into replenish_event values (4902016227380, 73123, 64335, 64373, '2022-05-12 20:10:10', 7, 4371);
insert into replenish_event values (3961290048137, 51232, 34817, 54335, '2022-08-23 02:05:59', 2, 1238);
insert into replenish_event values (9144706592862, 48262, 94534, 52355, '2022-11-05 16:37:23', 9, 1518);


