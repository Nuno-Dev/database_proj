----------------------------------------------------------------
-- init

DROP TRIGGER IF EXISTS verify_category ON has_other;
DROP TRIGGER IF EXISTS verify_replenish_units ON replenish_event;
DROP TRIGGER IF EXISTS verify_replenish_product ON replenish_event;

----------------------------------------------------------------
-- RI-1--

CREATE OR REPLACE FUNCTION verify_category_trigger_procedure() RETURNS TRIGGER AS $$
BEGIN
    IF new.category_name == new.supercategory_name THEN
        RAISE EXCEPTION 'Category cannot be contained inside itself';
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER verify_category AFTER INSERT OR UPDATE ON has_other
FOR EACH ROW EXECUTE PROCEDURE verify_category_trigger_procedure();

----------------------------------------------------------------
-- RI-4--

CREATE OR REPLACE FUNCTION verify_replenish_units_trigger_procedure() RETURNS TRIGGER AS $$
DECLARE limit_units INTEGER := 0;
BEGIN
    select planogram_units into limit_units 
    from planogram
    where shelve_number == new.shelve_number;

    IF new.replenish_event_units > limit_units THEN
        RAISE EXCEPTION 'The units to replenish exceed the planogram limit.';
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER verify_replenish_units AFTER INSERT OR UPDATE ON replenish_event
FOR EACH ROW EXECUTE PROCEDURE verify_replenish_units_trigger_procedure();

----------------------------------------------------------------
-- RI-5--

CREATE OR REPLACE FUNCTION verify_replenish_product_trigger_procedure() RETURNS TRIGGER AS $$
DECLARE product_category VARCHAR(80) := '';
DECLARE shelve_category VARCHAR(80) := '';
BEGIN
    select category_name into product_category
    from has_category
    where product_ean == new.product_ean;

    select category_name into shelve_category
    from shelve
    where shelve_number == new.shelve_number;

    IF product_category != shelve_category or product_category not in 
    (select category_name
    from has_other
    where supercategory_name == shelve_category) 
    THEN
        RAISE EXCEPTION 'The product cannot be replenished into a shelve of a different category';
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER verify_replenish_product AFTER INSERT OR UPDATE ON replenish_event
FOR EACH ROW EXECUTE PROCEDURE verify_replenish_product_trigger_procedure();
