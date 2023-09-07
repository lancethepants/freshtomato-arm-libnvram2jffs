#include <string.h>
#include <stddef.h>
#include <regex.h>

#include <shared.h>
#include <bcmnvram.h>

#define MAX_NVRAM_SPACE_JFFS	1048576

extern char *nvram_get_jffs(const char *key);
extern int nvram_getall_jffs(char *buf, size_t len);
extern int nvram_set_jffs(const char *key, const char *val);
extern int nvram_unset_jffs(const char *key);

extern char *nvram_get_traditional(const char *key);
extern int nvram_getall_traditional(char *buf, int count);
extern int nvram_set_traditional(const char *key, const char *val);
extern int nvram_unset_traditional(const char *key);

int in_jffs(const char *name)
{
	regex_t regex;

	if (nvram_get_int("nvram2jffs_enable") == 1)
		if (regcomp(&regex, nvram_get_traditional("nvram2jffs_regex"), REG_EXTENDED) == 0)
			if(regexec(&regex, name, 0, NULL, 0) == 0)
				return 1;

	return 0;
}

char *nvram_get(const char *name)
{
	if (strcmp(name, "jffs2_on") == 0)
		return nvram_get_traditional("jffs2_on");

	if (strcmp(name, "nvram2jffs_enable") == 0)
		return nvram_get_traditional("nvram2jffs_enable");

	if (strcmp(name, "nvram2jffs_regex") == 0)
		return nvram_get_traditional("nvram2jffs_regex");

	if (in_jffs(name)){
		return nvram_get_jffs(name);
	} else {
		return nvram_get_traditional(name);
	}
}

int nvram_set(const char *name, const char *value)
{
	if (strcmp(name, "jffs2_on") == 0)
		return nvram_set_traditional(name, value);

	if (strcmp(name, "nvram2jffs_enable") == 0)
		return nvram_set_traditional(name, value);

	if (strcmp(name, "nvram2jffs_regex") == 0)
		return nvram_set_traditional(name, value);

	if (in_jffs(name)){
		return nvram_set_jffs(name, value);
	} else {
		return nvram_set_traditional(name, value);
	}
}

int nvram_unset(const char *name)
{
	if (in_jffs(name)){
		return nvram_unset_jffs(name);
	} else {
		return nvram_unset_traditional(name);
	}
}

int nvram_getall(char *buf, int count)
{
	char buf1[count];
	char buf2[MAX_NVRAM_SPACE_JFFS];
	int pos = 0;
	char *value;

	nvram_getall_traditional(buf1, count);
	nvram_getall_jffs(buf2, sizeof(buf2));

	for (value = buf1; *value; value += strlen(value) + 1) {
		memcpy(buf + pos, value, strlen(value));
		pos += strlen(value) + 1;
	}

	for (value = buf2; *value; value += strlen(value) + 1) {
		memcpy(buf + pos, value, strlen(value));
		pos += strlen(value) + 1;
	}
	return 0;
}

void nvram_relocate_variables(void)
{
	if (nvram_get_int("jffs2_on") == 1){
		char *name, *value;
		char buf1[MAX_NVRAM_SPACE];
		char buf2[MAX_NVRAM_SPACE_JFFS];

		if (nvram_get_int("nvram2jffs_enable") == 1){

			nvram_getall_traditional(buf1, MAX_NVRAM_SPACE);

			for (value = buf1; *value; value += strlen(value) + 1) {
				name = strsep(&value, "=");
				if(in_jffs(name)){
					nvram_set_jffs(name, value);
					nvram_unset_traditional(name);
				}
			}
		}

		nvram_getall_jffs(buf2, MAX_NVRAM_SPACE_JFFS);

		for (value = buf2; *value; value += strlen(value) + 1) {
			name = strsep(&value, "=");
			if(!in_jffs(name)){
				nvram_set_traditional(name, value);
				nvram_unset_jffs(name);
			}
		}
		// commit is for traditional nvram
		// values stored in jffs are automatically commited (written to disk) when set
		nvram_commit();
	}
}
