#!/usr/bin/env python3
# -*- coding: utf-8 -*-

r"""
snapshot_dir_to_deployer.py

Генератор deploy-скрипта для развёртывания файловой инфраструктуры.

Скрипт принимает набор директорий и/или файлов, вычисляет их общий корень
в файловой системе и генерирует Python-скрипт, который при запуске
воссоздаёт эту инфраструктуру относительно целевой директории.

ОБЩАЯ ЛОГИКА

  1. Собираются все пути из параметров:
       --dirs  (директории)
       --files (отдельные файлы)

  2. Вычисляется общий корень (common root) этих путей:
       - для директорий: сам путь директории;
       - для файлов: директория файла (parent).

     Вся инфраструктура разворачивается ИМЕННО относительно этого общего корня.

  3. Генератор создаёт deploy-скрипт, который:
       - по умолчанию разворачивает структуру в текущей директории запуска
         deploy-скрипта;
       - опционально принимает параметр --target для указания иной директории.

  4. Имя deploy-скрипта:
       - если указан -o/--output, используется это имя как есть;
       - иначе:
           base_name = --name или имя общего корня
           deploy-файл: <base_name>_<YYYYMMDD_HHMMSS>.py

ОБЯЗАТЕЛЬНО: хотя бы один из параметров --dirs или --files должен быть указан.
"""

import argparse
import os
from pathlib import Path
from datetime import datetime


GENERATOR_VERSION = "3.0.0"


def common_root_for_dirs_and_files(dir_paths, file_paths):
    """
    Вычисляет общий корень (Path) для набора директорий и файлов.

    Для директорий используется сам путь директории, для файлов — parent.
    """
    candidates = []

    for d in dir_paths:
        candidates.append(d.resolve())

    for f in file_paths:
        candidates.append(f.resolve().parent)

    if not candidates:
        raise ValueError("Не передано ни одной директории или файла для вычисления общего корня.")

    parts_lists = [p.parts for p in candidates]
    common_parts = []
    for combo in zip(*parts_lists):
        if len(set(combo)) == 1:
            common_parts.append(combo[0])
        else:
            break

    if not common_parts:
        first = candidates[0]
        if first.anchor:
            return Path(first.anchor)
        if first.drive:
            return Path(first.drive + "\\")
        return Path(first.root)

    return Path(*common_parts)


def collect_from_dirs_and_files(common_root: Path, dir_paths, file_paths, include_content: bool):
    """
    Собирает структуру директорий и файлов относительно общего корня.

    :return: (dirs, files), где:
             dirs  - список относительных Path каталогов (относительно common_root),
             files - список кортежей (rel_path: Path, content: bytes|None).
    """
    dirs = set()
    files = []

    # Директории
    for d in dir_paths:
        d = d.resolve()
        for dirpath, _, filenames in os.walk(d):
            dirpath_p = Path(dirpath)
            rel_dir = dirpath_p.relative_to(common_root)
            dirs.add(rel_dir)
            for fname in filenames:
                fp = dirpath_p / fname
                rel_file = fp.relative_to(common_root)
                if include_content:
                    with fp.open("rb") as f:
                        content = f.read()
                else:
                    content = None
                files.append((rel_file, content))

    # Отдельные файлы
    for f in file_paths:
        f = f.resolve()
        rel_file = f.relative_to(common_root)
        if include_content:
            with f.open("rb") as fh:
                content = fh.read()
        else:
            content = None
        files.append((rel_file, content))

    dirs_sorted = sorted(dirs, key=lambda p: len(p.parts))
    return dirs_sorted, files


def generate_deploy_script(
    common_root: Path,
    rel_dirs,
    rel_files,
    output: Path,
    base_name: str,
):
    """
    Генерирует deploy-скрипт, который разворачивает инфраструктуру:

      TARGET_ROOT/
        <структура rel_dirs / rel_files>

    По умолчанию TARGET_ROOT = текущая директория запуска deploy-скрипта.
    """
    generated_at = datetime.now().isoformat(timespec="seconds")
    common_root_raw = str(common_root)
    common_root_escaped = common_root_raw.replace("\\", "\\\\")

    lines = []

    lines.append("#!/usr/bin/env python3")
    lines.append("# -*- coding: utf-8 -*-")
    lines.append("")
    lines.append('"""')
    lines.append(
        f"Автоматически сгенерированный deploy-скрипт для инфраструктуры '{base_name}'."
    )
    lines.append("")
    lines.append("Метаданные:")
    lines.append(f"  * Общий корень инфраструктуры (на момент генерации): {common_root_escaped}")
    lines.append(f"  * Дата генерации: {generated_at}")
    lines.append(f"  * Версия генератора: {GENERATOR_VERSION}")
    lines.append("")
    lines.append(
        "При запуске по умолчанию разворачивает структуру в текущей директории "
        "запуска скрипта; опционально можно указать иной каталог через --target."
    )
    lines.append("")
    lines.append("Примеры использования:")
    lines.append("")
    lines.append("    # Развёртывание в текущую директорию")
    lines.append(f"    python {output.name}")
    lines.append("")
    lines.append("    # Развёртывание в другую директорию")
    lines.append(f"    python {output.name} --target ./deploy_here")
    lines.append('"""')
    lines.append("")
    lines.append("import argparse")
    lines.append("from pathlib import Path")
    lines.append("")
    lines.append("")
    lines.append(f"BASE_NAME = {base_name!r}")
    lines.append(f"GENERATOR_VERSION = {GENERATOR_VERSION!r}")
    lines.append(f"GENERATED_AT = {generated_at!r}")
    lines.append(f"COMMON_ROOT = {common_root_escaped!r}")
    lines.append("")
    lines.append("")
    lines.append("def apply_structure(target_root: Path):")
    lines.append("    \"\"\"")
    lines.append("    Создаёт директории и файлы в целевой директории target_root.")
    lines.append("")
    lines.append("    Структура полностью соответствует структуре относительно COMMON_ROOT.")
    lines.append("    \"\"\"")
    lines.append("    base_dir = target_root.resolve()")
    lines.append("")
    lines.append("    # Создание директорий")
    for d in rel_dirs:
        if str(d) == ".":
            continue
        rel_str = str(d).replace("\\", "/")
        lines.append(f"    (base_dir / {rel_str!r}).mkdir(parents=True, exist_ok=True)")
    lines.append("")
    lines.append("    # Создание файлов")
    for rel_file, content in rel_files:
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
    lines.append("        --target TARGET")
    lines.append("            Каталог, в котором разворачивать структуру.")
    lines.append("            По умолчанию: текущая директория запуска скрипта.")
    lines.append("")
    lines.append("    Примеры:")
    lines.append("")
    lines.append(f"        python {output.name}")
    lines.append(f"        python {output.name} --target ./out_root")
    lines.append("")
    lines.append("    :return: Path к целевой директории.")
    lines.append("    \"\"\"")
    lines.append("    parser = argparse.ArgumentParser(")
    lines.append("        description=(")
    lines.append(
        "            'Развёртывает файловую инфраструктуру в каталоге TARGET "
        "(по умолчанию текущая директория).'"
    )
    lines.append("        )")
    lines.append("    )")
    lines.append("    parser.add_argument(")
    lines.append("        '--target',")
    lines.append(
        "        help=('Каталог, в котором разворачивать структуру. "
        "По умолчанию: текущая директория.')"
    )
    lines.append("    )")
    lines.append("    args = parser.parse_args()")
    lines.append("    if args.target:")
    lines.append("        target_root = Path(args.target)")
    lines.append("    else:")
    lines.append("        target_root = Path('.')")
    lines.append("    return target_root")
    lines.append("")
    lines.append("")
    lines.append("def main():")
    lines.append("    \"\"\"")
    lines.append("    Точка входа deploy-скрипта.")
    lines.append("")
    lines.append("    Определяет целевую директорию и разворачивает в неё структуру.")
    lines.append("    \"\"\"")
    lines.append("    target_root = parse_args()")
    lines.append("    apply_structure(target_root)")
    lines.append("")
    lines.append("")
    lines.append("if __name__ == '__main__':")
    lines.append("    main()")
    lines.append("")

    output.write_text("\n".join(lines), encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser(
        description=(
            "Генерирует Python-скрипт для развёртывания файловой инфраструктуры.\n\n"
            "Обязательные данные:\n"
            "  --dirs  : директории, входящие в инфраструктуру (можно несколько);\n"
            "  --files : отдельные файлы, входящие в инфраструктуру (опционально).\n"
            "Хотя бы один из параметров (--dirs или --files) обязателен.\n\n"
            "Имя и местоположение deploy-скрипта:\n"
            "  -o/--output      : полное имя файла, если нужно задать явно;\n"
            "  --output-dir     : каталог, куда сохранить deploy-скрипт;\n"
            "  --name           : базовое имя (без .py), если -o не задан.\n\n"
            "Развёртывание:\n"
            "  deploy-скрипт по умолчанию разворачивает структуру в текущей\n"
            "  директории запуска; можно указать другую через его параметр --target.\n\n"
            "Примеры:\n"
            "  # 1. Снимок одной директории\n"
            "  snapshot_dir_to_deployer.py --dirs ./PS/BackupOpticalDisk\n\n"
            "  # 2. Несколько директорий и файлов\n"
            "  snapshot_dir_to_deployer.py \\\n"
            "      --dirs ./src ./config \\\n"
            "      --files ./README.md ./LICENSE\n\n"
            "  # 3. Записать deploy-скрипт в отдельный каталог\n"
            "  snapshot_dir_to_deployer.py \\\n"
            "      --dirs ./infra \\\n"
            "      --output-dir ./deploy_scripts\n\n"
            "  # 4. Полностью задать имя deploy-скрипта\n"
            "  snapshot_dir_to_deployer.py \\\n"
            "      --dirs ./PS/BackupOpticalDisk \\\n"
            "      -o deploy_backup_infra.py\n"
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument(
        "--dirs",
        nargs="+",
        help=(
            "Одна или несколько директорий, которые войдут в инфраструктуру. "
            "Каждая директория будет развёрнута со своей структурой и содержимым."
        ),
    )

    parser.add_argument(
        "--files",
        nargs="+",
        help=(
            "Один или несколько отдельных файлов, которые войдут в инфраструктуру."
        ),
    )

    parser.add_argument(
        "--output-dir",
        help=(
            "Каталог, куда сохранить deploy-скрипт. "
            "По умолчанию: текущая директория запуска генератора."
        ),
    )

    parser.add_argument(
        "-o",
        "--output",
        help=(
            "Полное имя файла deploy-скрипта (с расширением .py). "
            "Если указано, игнорируются --name и автоформирование имени."
        ),
    )

    parser.add_argument(
        "--name",
        help=(
            "Базовое имя deploy-скрипта (без расширения), если -o не задан. "
            "Если не указано, берётся имя общего корня инфраструктуры."
        ),
    )

    parser.add_argument(
        "--no-content",
        action="store_true",
        help="Не встраивать содержимое файлов, создавать только пустые файлы.",
    )

    args = parser.parse_args()

    if not args.dirs and not args.files:
        parser.error("Необходимо указать хотя бы один из параметров: --dirs или --files")

    return args


def main_cli():
    args = parse_args()
    include_content = not args.no_content

    # Куда сохранить deploy-скрипт
    if args.output_dir:
        output_dir = Path(args.output_dir).resolve()
        output_dir.mkdir(parents=True, exist_ok=True)
    else:
        output_dir = Path.cwd().resolve()

    # Подготовка путей
    dir_paths = [Path(d).resolve() for d in (args.dirs or [])]
    file_paths = [Path(f).resolve() for f in (args.files or [])]

    # Общий корень
    common_root = common_root_for_dirs_and_files(dir_paths, file_paths)

    # Собираем относительную структуру
    rel_dirs, rel_files = collect_from_dirs_and_files(
        common_root, dir_paths, file_paths, include_content=include_content
    )

    # Имя файла deploy-скрипта и base_name
    if args.output:
        out = output_dir / args.output
        if args.name:
            base_name = args.name
        else:
            base_name = Path(args.output).stem or (common_root.name or "infra")
    else:
        if args.name:
            base_name = args.name
        else:
            base_name = common_root.name or "infra"
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{base_name}_{ts}.py"
        out = output_dir / filename

    generate_deploy_script(
        common_root=common_root,
        rel_dirs=rel_dirs,
        rel_files=rel_files,
        output=out,
        base_name=base_name,
    )

    print(f"Скрипт развёртывания сгенерирован: {out}")


if __name__ == "__main__":
    main_cli()