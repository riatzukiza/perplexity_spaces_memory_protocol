# Perplexity knowledge base
A system of memory, prompts, and scripts taylored for perplexity agents.

## Structure
The files in the project root establish the core protocol, and help the agent bootstrap their sandbox in as few turns as possible.
Every folder with any of the well known file names like `AGENTS.md` is a module.
Modules can have files with other names in them,
but the well known file or files with in the module must run or advertise those resources.

### Well Known files

- `AGENTS.md`
- `SETUP.sh`
- `.bash_profile`: using a bash profile will allow environment variables to persist between tool calls and turns

### `user/`
These are prompts and scripts expected to be useful to a perplexity agent operating with out a space.
