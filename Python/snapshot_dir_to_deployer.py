#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
snapshot_dir_to_deployer.py

Скрипт принимает путь к директории и генерирует Python-скрипт, который при запуске
воссоздаст структуру (и, опционально, содержимое файлов) этой директории.

По умолчанию имя выходного файла формируется как:
    deploy_<имя_директории>_<YYYYMMDD_HHMMSS>.py

Ограничения и предупреждения:

  * Встраивание содержимого файлов происходит побайтно в виде литералов bytes.
    Для больших файлов (десятки/сотни МБ) это приведёт к громоздкому и тяжёлому
    для загрузки/редактирования .py-скрипту.

  * Для крупных бинарников (архивы, образы, мультимедиа) рекомендуется либо
    использовать режим --no-content (создание только структуры), либо включать
    такие файлы в деплой другим способом (отдельный архив, артефакт CI/CD и т.п.).

Примеры использования:

    # 1. Сгенерировать скрипт развёртывания с содержимым файлов
    python snapshot_dir_to_deployer.py ./MyProject

    # 2. Сгенерировать скрипт с явным именем
    python snapshot_dir_to_deployer.py ./MyProject -o myproject_deploy.py -n MyProject

    # 3. Сгенерировать только структуру (без содержимого файлов)
    python snapshot_dir_to_deployer.py ./MyProject --no-content

    # 4. Абсолютный путь к исходной директории
    python snapshot_dir_to_deployer.py "C:\\Work\\MyProject" -o deploy_work_myproject.py
"""

import argparse
import os
from pathlib import Path
from datetime import datetime


GENERATOR_VERSION = "1.0.0"


def collect_structure(root: Path, include_content: bool):
    """
    Обходит дерево файлов и каталогов, начиная с root, и собирает
    описание структуры для дальнейшей генерации скрипта развёртывания.

    :param root: Корневая директория, структуру которой нужно сохранить.
    :param include_content: Если True, содержимое файлов будет считано и встроено
                            в будущий скрипт; если False, создаются только пустые файлы.
    :return: Кортеж (dirs, files), где:
             - dirs: список относительных путей каталогов (Path), отсортированных
                     по глубине (корень первым);
             - files: список кортежей (rel_path, content), где rel_path — относительный
                      путь к файлу (Path), content — bytes или None.
    """
    root = root.resolve()
    dirs = []
    files = []

    for dirpath, dirnames, filenames in os.walk(root):
        dir_path = Path(dirpath)
        rel_dir = dir_path.relative_to(root)
        dirs.append(rel_dir)

        for fname in filenames:
            file_path = dir_path / fname
            rel_file = file_path.relative_to(root)

            if include_content:
                with file_path.open("rb") as f:
                    content = f.read()
            else:
                content = None

            files.append((rel_file, content))

    dirs_sorted = sorted(set(dirs), key=lambda p: len(p.parts))
    return dirs_sorted, files


def generate_deploy_script(root: Path, dirs, files, output: Path, project_name: str):
    """
    Генерирует Python-скрипт, который создаёт директорию проекта внутри целевой
    директории и разворачивает структуру уже в ней.

    Итоговая схема при запуске deploy-скрипта:

        <target_root>/
            <project_name>/   <- создаётся автоматически (по умолчанию)
                ... здесь вся сгенерированная структура ...

    CLI сгенерированного файла:

        usage: deploy_<name>.py [-h] [--target TARGET] [--no-project-dir]

        Опции:
          -h, --help        показать справку и выйти
          --target TARGET   каталог, в котором разворачивать структуру
                            (по умолчанию: текущая директория)
          --no-project-dir  не создавать дополнительную папку проекта, разворачивать
                            структуру прямо в TARGET
    """
    root_name = project_name or root.name
    generated_at = datetime.now().isoformat(timespec="seconds")
    source_root_raw = str(root.resolve())
    # Экранируем backslash'и для корректного размещения в строковом литерале
    source_root_escaped = source_root_raw.replace("\\", "\\\\")

    lines = []

    lines.append("#!/usr/bin/env python3")
    lines.append("# -*- coding: utf-8 -*-")
    lines.append("")
    lines.append('"""')
    lines.append(
        f"Автоматически сгенерированный скрипт для развёртывания структуры '{root_name}'."
    )
    lines.append("")
    lines.append("Метаданные:")
    lines.append(f"  * Исходный путь: {source_root_escaped}")
    lines.append(f"  * Дата генерации: {generated_at}")
    lines.append(f"  * Версия генератора: {GENERATOR_VERSION}")
    lines.append("")
    lines.append("При запуске по умолчанию создаёт директорию проекта внутри целевой")
    lines.append("директории (TARGET/PROJECT_NAME) и разворачивает структуру внутри неё.")
    lines.append("Опционально можно разворачивать прямо в TARGET (флаг --no-project-dir).")
    lines.append("")
    lines.append("Примеры использования:")
    lines.append("")
    lines.append(f"    # Развёртывание в текущую директорию (./{root_name})")
    lines.append(f"    python deploy_{root_name}.py")
    lines.append("")
    lines.append(
        f"    # Развёртывание в указанную директорию (./deploy_root/{root_name})"
    )
    lines.append(f"    python deploy_{root_name}.py --target ./deploy_root")
    lines.append("")
    lines.append(
        "    # Развёртывание прямо в указанную директорию (без подпапки проекта)"
    )
    lines.append(
        f"    python deploy_{root_name}.py --target ./deploy_root --no-project-dir"
    )
    lines.append('"""')
    lines.append("")
    lines.append("import argparse")
    lines.append("from pathlib import Path")
    lines.append("")
    lines.append("")
    lines.append(f"PROJECT_NAME = {root_name!r}")
    lines.append(f"GENERATOR_VERSION = {GENERATOR_VERSION!r}")
    lines.append(f"GENERATED_AT = {generated_at!r}")
    lines.append(f"SOURCE_ROOT = {source_root_escaped!r}")
    lines.append("")
    lines.append("")
    lines.append("def apply_structure(target_root: Path, use_project_dir: bool = True):")
    lines.append("    \"\"\"")
    lines.append("    Создаёт директории и файлы в целевой директории.")
    lines.append("")
    lines.append("    Если use_project_dir=True, структура разворачивается в")
    lines.append("    target_root / PROJECT_NAME. Если False — прямо в target_root.")
    lines.append("")
    lines.append("    :param target_root: Каталог, в котором разворачивать структуру.")
    lines.append("    :param use_project_dir: Создавать ли подкаталог проекта.")
    lines.append("    \"\"\"")
    lines.append("    target_root = target_root.resolve()")
    lines.append("    if use_project_dir:")
    lines.append("        base_dir = target_root / PROJECT_NAME")
    lines.append("        base_dir.mkdir(parents=True, exist_ok=True)")
    lines.append("    else:")
    lines.append("        base_dir = target_root")
    lines.append("")
    lines.append("    # Создание директорий")
    for d in dirs:
        if str(d) == ".":
            continue
        rel_str = str(d).replace("\\", "/")
        lines.append(f"    (base_dir / {rel_str!r}).mkdir(parents=True, exist_ok=True)")
    lines.append("")
    lines.append("    # Создание файлов")
    for rel_file, content in files:
        rel_str = str(rel_file).replace("\\", "/")
        lines.append(f"    file_path = base_dir / {rel_str!r}")
        lines.append("    file_path.parent.mkdir(parents=True, exist_ok=True)")
        if content is None:
            lines.append("    if not file_path.exists():")
            lines.append("        file_path.touch()")
        else:
            b = content
            chunk_size = 60
            chunks = [b[i:i + chunk_size] for i in range(0, len(b), chunk_size)]
            if not chunks:
                lines.append("    file_path.write_bytes(b'')")
            else:
                lines.append("    _data = b''")
                for ch in chunks:
                    lines.append(f"    _data += {ch!r}")
                lines.append("    file_path.write_bytes(_data)")
        lines.append("")

    lines.append("")
    lines.append("def parse_args():")
    lines.append("    \"\"\"")
    lines.append("    Разбирает аргументы командной строки deploy-скрипта.")
    lines.append("")
    lines.append("    Параметры:")
    lines.append("")
    lines.append("        --target TARGET      Каталог, в котором разворачивать структуру.")
    lines.append("                            По умолчанию: текущая директория.")
    lines.append("        --no-project-dir    Не создавать подкаталог проекта, разворачивать")
    lines.append("                            структуру прямо в TARGET.")
    lines.append("")
    lines.append("    Примеры:")
    lines.append("")
    lines.append(f"        python deploy_{root_name}.py")
    lines.append(f"        python deploy_{root_name}.py --target ./out_root")
    lines.append(
        f"        python deploy_{root_name}.py --target ./out_root --no-project-dir"
    )
    lines.append("")
    lines.append("    :return: (target_root: Path, use_project_dir: bool).")
    lines.append("    \"\"\"")
    lines.append("    parser = argparse.ArgumentParser(")
    lines.append("        description=(")
    lines.append(
        "            'Развёртывает структуру проекта в каталоге TARGET или TARGET/PROJECT_NAME.'"
    )
    lines.append("        )")
    lines.append("    )")
    lines.append("    parser.add_argument(")
    lines.append("        '--target',")
    lines.append("        help=('Каталог, в котором разворачивать структуру. '")
    lines.append("              'По умолчанию: текущая директория.'),")
    lines.append("    )")
    lines.append("    parser.add_argument(")
    lines.append("        '--no-project-dir',")
    lines.append("        action='store_true',")
    lines.append("        help=('Не создавать подкаталог проекта, разворачивать структуру '")
    lines.append("             'прямо в TARGET.'),")
    lines.append("    )")
    lines.append("    args = parser.parse_args()")
    lines.append("    target_root = Path(args.target) if args.target else Path('.')")
    lines.append("    use_project_dir = not args.no_project_dir")
    lines.append("    return target_root, use_project_dir")
    lines.append("")
    lines.append("")
    lines.append("def main():")
    lines.append("    \"\"\"")
    lines.append("    Точка входа deploy-скрипта.")
    lines.append("")
    lines.append("    Читает аргументы командной строки, определяет целевую директорию ROOT")
    lines.append("    и разворачивает структуру в ROOT или ROOT / PROJECT_NAME в зависимости")
    lines.append("    от флага --no-project-dir.")
    lines.append("    \"\"\"")
    lines.append("    target_root, use_project_dir = parse_args()")
    lines.append("    apply_structure(target_root, use_project_dir=use_project_dir)")
    lines.append("")
    lines.append("")
    lines.append("if __name__ == '__main__':")
    lines.append("    main()")
    lines.append("")

    output.write_text("\n".join(lines), encoding="utf-8")


def parse_args():
    """
    Разбирает аргументы командной строки для snapshot_dir_to_deployer.py.

    Поддерживаемые параметры:

        source              Исходная директория (обязательный позиционный параметр).
        -o, --output        Имя выходного Python-файла. Если не указано,
                            используется deploy_<имя_директории>_<YYYYMMDD_HHMMSS>.py.
        --no-content        Не встраивать содержимое файлов; создаются только пустые файлы.
        -n, --name          Логическое имя проекта для комментариев в сгенерированном скрипте.

    Рекомендации:

        * Для директорий с крупными бинарниками используйте --no-content,
          чтобы избежать генерации чрезмерно большого deploy-скрипта.

    Примеры:

        # Базовый сценарий: полный снимок
        python snapshot_dir_to_deployer.py ./MyProject

        # Явное имя выходного файла
        python snapshot_dir_to_deployer.py ./MyProject -o deploy_myproject.py

        # Только структура, без содержимого файлов
        python snapshot_dir_to_deployer.py ./MyProject --no-content

        # Задать логическое имя проекта
        python snapshot_dir_to_deployer.py ./MyProject -n MyProject

    :return: Объект argparse.Namespace с полями source, output, no_content, name.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Генерирует Python-скрипт для развёртывания структуры заданной директории.\n\n"
            "ВНИМАНИЕ: для больших бинарных файлов рекомендуется использовать опцию\n"
            "--no-content и доставлять эти файлы отдельно.\n\n"
            "Примеры:\n"
            "  snapshot_dir_to_deployer.py ./MyProject\n"
            "  snapshot_dir_to_deployer.py ./MyProject -o deploy_myproject.py\n"
            "  snapshot_dir_to_deployer.py ./MyProject --no-content\n"
            "  snapshot_dir_to_deployer.py ./MyProject -n MyProject"
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "source",
        help="Исходная директория (относительный или абсолютный путь).",
    )
    parser.add_argument(
        "-o",
        "--output",
        help=(
            "Имя выходного Python-файла. "
            "Если не указано, используется deploy_<имя_директории>_<YYYYMMDD_HHMMSS>.py."
        ),
    )
    parser.add_argument(
        "--no-content",
        action="store_true",
        help="Не встраивать содержимое файлов, создавать только пустые файлы.",
    )
    parser.add_argument(
        "-n",
        "--name",
        help="Логическое имя проекта для комментариев в сгенерированном скрипте.",
    )
    return parser.parse_args()


def main_cli():
    """
    Точка входа CLI для snapshot_dir_to_deployer.py.

    Читает аргументы командной строки, проверяет исходную директорию,
    формирует путь к выходному файлу и запускает генерацию скрипта развёртывания.
    """
    args = parse_args()
    src = Path(args.source)
    if not src.exists() or not src.is_dir():
        raise SystemExit(f"Source directory not found or not a directory: {src}")

    include_content = not args.no_content

    if args.output:
        out = Path(args.output)
    else:
        dir_name = src.resolve().name
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        out = Path(f"deploy_{dir_name}_{ts}.py")

    dirs, files = collect_structure(src, include_content=include_content)
    generate_deploy_script(src, dirs, files, out, project_name=args.name)

    print(f"Скрипт развёртывания сгенерирован: {out}")


if __name__ == "__main__":
    main_cli()
