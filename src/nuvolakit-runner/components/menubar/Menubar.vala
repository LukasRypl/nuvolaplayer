/*
 * Copyright 2014 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace Nuvola
{

public class MenuBar: GLib.Object, MenuBarInterface
{
	private Diorite.ActionsRegistry actions_reg;
	private HashTable<string, SubMenu> menus;
	private Menu? menubar = null;
	private Menu? app_menu = null;
	
	public MenuBar(Diorite.ActionsRegistry actions_reg)
	{
		this.actions_reg = actions_reg;
		this.menus = new HashTable<string, SubMenu>(str_hash, str_equal);
		menubar = new Menu();
		app_menu = new Menu();
	}
	
	public void set_app_menu(Gtk.Application app, string[] actions)
	{
		app_menu.remove_all();
		actions_reg.append_to_menu(app_menu, actions, true, false);
		if (app.app_menu == null)
		{
			if (app.get_windows() != null)
				warning("Cannot set an app menu because an app window has been already created.");
			else
				app.set_app_menu(app_menu);
		}
		else if (app.app_menu != app_menu)
		{
			warning("The app menu have been already set to a different one.");
		}
	}
	
	public void set_menus(Gtk.Application app)
	{
		app.set_menubar(menubar);
	}
	
	public void update()
	{
		menubar.remove_all();
		var submenus = menus.get_keys();
		submenus.sort(strcmp);
		foreach (var submenu in submenus)
			menus[submenu].append_to_menu(actions_reg, menubar);
	}
	
	public void set_submenu(string id, SubMenu submenu)
	{
		menus[id] = submenu;
	}
	
	public bool set_menu(string id, string label, string[] actions)
	{
		set_submenu(id, new SubMenu(label, actions));
		update();
		return !Binding.CONTINUE;
	}
}

public class SubMenu
{
	public string label {get; private set;}
	private string[] actions;
	
	public SubMenu(string label, string[] actions)
	{
		this.label = label;
		this.actions = actions;
	}
	
	public void append_to_menu(Diorite.ActionsRegistry actions_reg, Menu menu)
	{
		menu.append_submenu(label, actions_reg.build_menu(actions, true, false));
	}
}

} // namespace Nuvola
