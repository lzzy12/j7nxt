/*
 * include/linux/input/doubletap2wake.h
 *
 * Copyright (c) 2013, Dennis Rassmann <showp1984@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
#include <linux/suspend.h>
#include <linux/suspend_ioctls.h>
#include <linux/utsname.h>
#include <linux/freezer.h>


#ifndef _LINUX_DOUBLETAP2WAKE_H
#define _LINUX_DOUBLETAP2WAKE_H

extern int dt2w_switch;
extern bool flg_sensor_prox_detecting;
extern bool flg_screen_report;

#endif	/* _LINUX_DOUBLETAP2WAKE_H */

/* kernel/power/autosleep.c */
extern int pm_autosleep_init(void);
extern int pm_autosleep_lock(void);
extern void pm_autosleep_unlock(void);
extern suspend_state_t pm_autosleep_state(void);
extern int pm_autosleep_set_state(suspend_state_t state);