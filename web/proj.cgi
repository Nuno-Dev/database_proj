#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras
# SGBD configs
DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist199292"
DB_DATABASE=DB_USER
DB_PASSWORD="db99292"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)
app = Flask(__name__)

@app.route('/')
def home():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        return render_template("home.html", cursor=cursor)
    except Exception as e:
        return str(e) # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route('/category')
def update_category():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = 'SELECT category_name FROM category'
        cursor.execute(query)
        return render_template("category.html", cursor=cursor, params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()
        
@app.route('/delete-category', methods=["POST"])
def delete_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        category_name = request.form["category_name"]
        query = 'DELETE FROM has_other WHERE category_name = %s OR super_category_name = %s'
        cursor.execute(query,(category_name,category_name))
        queries = [
            'DELETE FROM super_category WHERE super_category_name = %s',
            'DELETE FROM simple_category WHERE simple_category_name = %s',
            'DELETE FROM has_category WHERE category_name = %s',
            'DELETE FROM planogram WHERE shelve_number IN \
                (SELECT shelve_number FROM shelve WHERE category_name = %s)',
            'DELETE FROM planogram WHERE product_ean IN \
                (SELECT product_ean FROM has_category WHERE category_name = %s)',
            'DELETE FROM replenish_event WHERE shelve_number IN \
                (SELECT shelve_number FROM shelve WHERE category_name = %s)',
            'DELETE FROM shelve WHERE category_name = %s',
            'DELETE FROM responsible_for WHERE category_name = %s',
            'DELETE FROM product WHERE category_name = %s',
            'DELETE FROM category WHERE category_name = %s']
        for query in queries:
            cursor.execute(query, (category_name,))
        return render_template("delete-category.html", cursor=cursor, params=category_name)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/add-category', methods=["POST"])
def add_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        category_name = request.form["add_category_name"]
        query = 'INSERT INTO category VALUES (%s)'
        cursor.execute(query, (category_name,))
        return render_template("add-category.html", cursor=cursor, params=category_name)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/retailer')
def update_retailer():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = 'SELECT retailer_tin, retailer_name FROM retailer'
        cursor.execute(query)
        return render_template("retailer.html", cursor=cursor, params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route('/delete-retailer', methods=["POST"])
def delete_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        retailer_tin = request.form["retailer_tin"]
        queries = [
            'DELETE FROM replenish_event WHERE retailer_tin = %s',
            'DELETE FROM responsible_for WHERE retailer_tin = %s',
            'DELETE FROM retailer WHERE retailer_tin = %s']
        for query in queries:
            cursor.execute(query, (retailer_tin,))
        return render_template("delete-retailer.html", cursor=cursor, params=retailer_tin)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/add-retailer', methods=["POST"])
def add_retailer():
    dbConn = None
    cursor = None
    try:    
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        retailer_tin = request.form["add_retailer_tin"]
        retailer_name = request.form["add_retailer_name"]
        query = 'INSERT INTO retailer VALUES (%s,%s)'
        cursor.execute(query,(retailer_tin, retailer_name))
        return render_template("add-retailer.html", cursor=cursor, params=retailer_name)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/ivm', methods=["POST"])
def get_ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        ivm_serial = request.form["ivm_serial"]
        query = 'SELECT x.category_name, SUM(x.replenish_event_units) AS total_units FROM \
            (SELECT category_name,replenish_event_units \
            FROM product INNER JOIN replenish_event ON (product.product_ean = replenish_event.product_ean)\
            WHERE ivm_serial_number = %s) AS x GROUP BY x.category_name'
        cursor.execute(query, (ivm_serial,))
        return render_template("ivm.html", cursor=cursor, params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/subcategory', methods=["POST"])
def get_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        supercategory_name = request.form["supercategory_name"]
        query = 'WITH RECURSIVE New AS \
            (SELECT category_name AS c FROM has_other \
            WHERE super_category_name = %s \
            UNION ALL SELECT category_name FROM New,has_other \
            WHERE New.c = has_other.super_category_name) \
            SELECT * FROM New'
        cursor.execute(query, (supercategory_name,))
        return render_template("subcategory.html", cursor=cursor, params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


        
CGIHandler().run(app)
