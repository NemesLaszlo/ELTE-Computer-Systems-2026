# ELTE Computer Systems

This repository contains the tasks, materials, and organisational details of the ELTE *Computer Systems* course.

### Contact
- Email: `laszlo.nemes@inf.elte.hu`
- MS Teams: `Nemes László`
- [Calendly](https://calendly.com/laszlo-nemes-elte) – book a call with me

### Canvas
https://canvas.elte.hu/

### ELTE server
- Server: `szamrend.inf.elte.hu`
- Login: The `neptun code` in lowercase and then the `password` (infes azonosító)
- Example: `ssh <your Neptun code is all lowercase>@szamrend.inf.elte.hu`

---

### Groups

#### Group 18
- **Time:** 2:15 PM – 3:45 PM (CET/CEST)
- **Location:** D 00-524 (PC4)

#### Group 12
- **Time:** 4:15 PM – 5:45 PM (CET/CEST)
- **Location:** D 00-411 (PC7)

---

### Key dates

**ZHs** (in-class tests):
- First ZH: **week 9** of the semester (November 11, 2026)
- Second ZH: **week 13** of the semester (December 9, 2026)

**ZH retakes:** during the first week of the exam period (December 14–18, 2026), at an agreed time.

---

### Requirements

#### Theory (Előadás)
**2 theory tests on Canvas** (10 + 10 points)
- 10 questions each, taken during the lecture
- One in the middle of the semester, one in the penultimate lecture

#### Practice (Gyakorlat)
**2 ZHs** (20 + 20 points)
1. **Unix – shell scripting**
   - Tasks solvable with basic bash commands
   - Shell scripts that perform a given task
2. **PowerShell**
   - PowerShell scripts that perform a given task

At least 50% must be achieved on each ZH.

**Assignments:**
1. Shell script task
2. PowerShell task

Late submission:
- Up to 1 week late: 5 points deducted from the total score
- Up to 2 weeks late: 10 points deducted from the total score
- More than 2 weeks late: the course is failed

---

### Grading

| Points | Grade |
|---|---|
| 0–29 | insufficient (1) |
| 30–37 | sufficient (2) |
| 38–45 | average (3) |
| 46–53 | good (4) |
| 54–60 | excellent (5) |

---

### Basic terms

A short glossary so we all mean the same thing by the same words.

**Unix** is an operating system developed at Bell Labs starting in 1969. Many modern operating systems – and many of the concepts and conventions we use today (files, processes, pipes, permissions) – originate from Unix.

**POSIX** (Portable Operating System Interface) is a family of IEEE/ISO standards that describe what a Unix-like system should provide: the shell and its command language, the basic command-line utilities, and the system APIs. Its purpose is portability – a script or program written against POSIX should run on any compliant system. Linux, macOS and the BSDs (BSD stands for Berkeley Software Distribution. It is a family of Unix-like operating systems.) follow POSIX to a large extent, which is why the commands you learn on one of them mostly work on the others.

**Linux** is a free and open-source operating system kernel designed along Unix principles and largely POSIX-compliant. Together with the GNU tools (GNU tools are a large collection of free software and programming utilities created by the GNU Project to build and run operating systems) and other software it forms the Linux distributions. (Ubuntu, Debian, Fedora, ...)

A **shell** is a command-line interface to the operating system: you type a command (e.g. `mkdir foldername`), the shell interprets it and runs it. **sh** was the original Unix shell; **bash**, **zsh** and others were created later to extend it, and several shells coexist today because they serve different needs. Bash is the most common one on Linux and is what we use in class.

**Shell scripting** means putting the commands you would otherwise type by hand into a text file, so the shell can execute them in sequence without you retyping them. Over time shells gained variables, conditionals, loops and functions, so shell scripts can express real programs – but at their core they still just run commands.

**PowerShell** is Microsoft's cross-platform automation tool: a command-line shell, a scripting language and a configuration management framework in one. Unlike Unix shells, which pass text between commands, PowerShell passes structured objects. It runs on Windows, Linux and macOS.