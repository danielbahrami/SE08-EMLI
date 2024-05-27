from flask import Flask, send_from_directory, render_template_string, request, redirect, url_for
import os

app = Flask(__name__)
BASE_DIR = ""

@app.route("/")
@app.route("/<path:subpath>")
def show_files(subpath=""):
    try:
        full_path = os.path.join(BASE_DIR, subpath)
        if os.path.isfile(full_path):
            return send_from_directory(os.path.dirname(full_path), os.path.basename(full_path))
        else:
            files = os.listdir(full_path)
            files_list = []
            for file in files:
                file_path = os.path.join(subpath, file)
                if os.path.isdir(os.path.join(BASE_DIR, file_path)):
                    file_path += "/"
                files_list.append(file_path)
            return render_template_string(TEMPLATE, files=files_list, parent=subpath)
    except Exception as e:
        return str(e)

TEMPLATE = """
<!doctype html>
<title>Wildlife Camera File Explorer</title>
<h1>Wildlife Camera File Explorer</h1>
<ul>
  <li><a href="{{ url_for("show_files", subpath="") }}">Home</a></li>
  {% if parent %}
  <li><a href="{{ url_for("show_files", subpath=parent.rsplit("/", 1)[0]) }}">..</a></li>
  {% endif %}
  {% for file in files %}
    <li><a href="{{ url_for("show_files", subpath=file) }}">{{ file }}</a></li>
  {% endfor %}
</ul>
"""

if __name__ == "__main__":
    app.run(port=5000)
