/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alain23@protonmail.com>
*/

public class Widgets.TaskNew : Gtk.Revealer {
    private Gtk.FlowBox labels_flowbox;
    public Gtk.Entry name_entry;
    private Gtk.TextView note_view;
    private Gtk.Button close_button;
    private Gtk.ListBox checklist;
    public Widgets.WhenButton when_button;

    public bool is_inbox { get; construct; }
    public int project_id { get; construct; }

    private Objects.Task task;
    public GLib.DateTime when_datetime {
        set {
            when_button.set_date (value, false, new GLib.DateTime.now_local ());
        }
    }

    public signal void on_signal_close ();
    public TaskNew (bool _is_inbox = false, int _project_id = 0) {
        Object (
            is_inbox: _is_inbox,
            project_id: _project_id,
            margin_start: 18,
            margin_end: 9,
            reveal_child: false,
            transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN
        );
    }

    construct {
        task = new Objects.Task ();

        name_entry = new Gtk.Entry ();
        name_entry.margin_start = 12;
        name_entry.margin_end = 6;
        name_entry.margin_top = 6;
        name_entry.hexpand = true;
        name_entry.placeholder_text = _("New task");
        name_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        name_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        name_entry.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        name_entry.get_style_context ().add_class ("planner-entry");

        close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        close_button.get_style_context ().add_class ("button-close");
        close_button.height_request = 24;
        close_button.width_request = 24;
        close_button.can_focus = false;
        close_button.valign = Gtk.Align.START;
        close_button.halign = Gtk.Align.START;

        /* Note */
        var source_buffer = new Gtk.SourceBuffer (null);
        source_buffer.highlight_syntax = true;
        source_buffer.language = Gtk.SourceLanguageManager.get_default ().get_language ("markdown");

        if (Application.settings.get_boolean ("prefer-dark-style")) {
            source_buffer.style_scheme = new Gtk.SourceStyleSchemeManager ().get_scheme ("solarized-dark");
        } else {
            source_buffer.style_scheme = new Gtk.SourceStyleSchemeManager ().get_scheme ("solarized-light");
        }

        Application.settings.changed.connect ((key) => {
            if (key == "prefer-dark-style") {
                if (Application.settings.get_boolean ("prefer-dark-style")) {
                    source_buffer.style_scheme = new Gtk.SourceStyleSchemeManager ().get_scheme ("solarized-dark");
                } else {
                    source_buffer.style_scheme = new Gtk.SourceStyleSchemeManager ().get_scheme ("solarized-light");
                }
            }
        });

        note_view = new Gtk.SourceView ();
        note_view.expand = true;
        note_view.wrap_mode = Gtk.WrapMode.WORD;
        note_view.height_request = 50;
        note_view.margin_start = 12;
        note_view.margin_top = 6;
        note_view.margin_end = 12;
        note_view.monospace = true;
        note_view.buffer = source_buffer;

        note_view.get_style_context ().add_class ("note-view");
        
        var note_view_placeholder_label = new Gtk.Label (_("Note"));
        note_view_placeholder_label.opacity = 0.65;
        note_view.add (note_view_placeholder_label);

        if (note_view.buffer.text != "") {
            note_view_placeholder_label.visible = false;
            note_view_placeholder_label.no_show_all = true;
        }

        var note_eventbox = new Gtk.EventBox ();
        note_eventbox.add (note_view);

        /*
        var preview_view = new Gtk.ScrolledWindow (null, null);
        preview_view.expand = true;

        var preview_view_content = new Widgets.WebView (task);
        preview_view.add (preview_view_content);

        var note_stack = new Gtk.Stack ();
        note_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        note_stack.expand = true;

        note_stack.add_named (note_eventbox, "note_edit");
        note_stack.add_named (preview_view, "note_view");

        var mode_button = new Granite.Widgets.ModeButton ();
        mode_button.get_style_context ().add_class ("format-bar");
        mode_button.hexpand = true;
        mode_button.margin_end = 24;
        mode_button.halign = Gtk.Align.END;
        mode_button.valign = Gtk.Align.START;

        mode_button.append_icon ("planner-text-symbolic", Gtk.IconSize.MENU);
        mode_button.append_icon ("planner-markdown-symbolic", Gtk.IconSize.MENU);

        mode_button.selected = 0;

        var note_view_overlay = new Gtk.Overlay ();
        note_view_overlay.add_overlay (mode_button);
        note_view_overlay.add (note_stack);

        mode_button.mode_changed.connect ((widget) => {
            if (mode_button.selected == 0) {
                note_stack.visible_child_name = "note_edit";
                preview_view.height_request = -1;
            } else if (mode_button.selected == 1){
                preview_view.height_request = 200;
                preview_view_content.update_note (note_view.buffer.text);
                note_stack.visible_child_name = "note_view";
            }
        });
        */

        checklist = new Gtk.ListBox  ();
        checklist.activate_on_single_click = true;
        checklist.get_style_context ().add_class ("view");
        checklist.selection_mode = Gtk.SelectionMode.SINGLE;

        var checklist_button = new Gtk.CheckButton ();
        checklist_button.get_style_context ().add_class ("planner-radio-disable");
        checklist_button.sensitive = false;

        var checklist_entry = new Gtk.Entry ();
        checklist_entry.hexpand = true;
        checklist_entry.margin_bottom = 1;
        checklist_entry.placeholder_text = _("Checklist");
        checklist_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        checklist_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        checklist_entry.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        checklist_entry.get_style_context ().add_class ("planner-entry");

        var checklist_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        checklist_box.pack_start (checklist_button, false, false, 0);
        checklist_box.pack_start (checklist_entry, true, true, 6);

        var checklist_grid = new Gtk.Grid ();
        checklist_grid.margin_start = 14;
        checklist_grid.margin_end = 12;
        checklist_grid.orientation = Gtk.Orientation.VERTICAL;
        checklist_grid.add (checklist);
        checklist_grid.add (checklist_box);

        labels_flowbox = new Gtk.FlowBox ();
        labels_flowbox.selection_mode = Gtk.SelectionMode.NONE;
        labels_flowbox.margin_start = 6;
        labels_flowbox.expand = false;

        var labels_flowbox_revealer = new Gtk.Revealer ();
        labels_flowbox_revealer.add (labels_flowbox);
        labels_flowbox_revealer.reveal_child = false;

        when_button = new Widgets.WhenButton ();

        var labels = new Widgets.LabelButton ();

        var submit_task_button = new Gtk.Button.with_label (_("Create Task"));
        submit_task_button.valign = Gtk.Align.CENTER;
        submit_task_button.sensitive = false;
        submit_task_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var bottom_box =  new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        bottom_box.margin_bottom = 6;
        bottom_box.margin_start = 6;
        bottom_box.margin_end = 6;
        bottom_box.pack_start (when_button, false, false, 0);
        bottom_box.pack_start (labels, false, false, 0);
        bottom_box.pack_end (submit_task_button, false, false, 0);

        var main_grid = new Gtk.Grid ();
        main_grid.expand = true;
        main_grid.margin_top = 3;
        main_grid.margin_end = 5;
        main_grid.margin_start = 5;
        main_grid.row_spacing = 6;
        main_grid.get_style_context ().add_class ("popover");
        main_grid.get_style_context ().add_class ("planner-popover");
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (name_entry);
        main_grid.add (note_eventbox);
        main_grid.add (checklist_grid);
        main_grid.add (labels_flowbox_revealer);
        main_grid.add (bottom_box);

        var main_overlay = new Gtk.Overlay ();
        main_overlay.expand = true;
        main_overlay.add_overlay (close_button);
        main_overlay.add (main_grid);

        add (main_overlay);

        close_button.clicked.connect (() => {
            on_signal_close ();
        });

        name_entry.activate.connect (add_task);
        name_entry.changed.connect (() => {
            if (name_entry.text == "") {
                submit_task_button.sensitive = false;
            } else {
                submit_task_button.sensitive = true;
            }

            name_entry.text = Application.utils.first_letter_to_up (name_entry.text);
        });

        name_entry.focus_in_event.connect (() => {
            name_entry.secondary_icon_name = "edit-clear-symbolic";
            return false;
        });

        name_entry.focus_out_event.connect (() => {
            name_entry.secondary_icon_name = null;
            return false;
        });

        name_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				name_entry.text = "";
			}
		});

        submit_task_button.clicked.connect (add_task);

        name_entry.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                on_signal_close ();
            }

            return false;
        });

        note_view.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                on_signal_close ();
            }

            return false;
        });

        labels.on_selected_label.connect ((label) => {
            if (is_repeted (label.id) == false) {
                var child = new Widgets.LabelChild (label);
                labels_flowbox.add (child);
            }

            labels_flowbox_revealer.reveal_child = !is_empty (labels_flowbox);
            show_all ();
        });

        labels_flowbox.remove.connect ((widget) => {
            labels_flowbox_revealer.reveal_child = !is_empty (labels_flowbox);
        });

        checklist_entry.activate.connect (() => {
            if (checklist_entry.text != "") {
                var row = new Widgets.CheckRow (checklist_entry.text, false);
                checklist.add (row);

                checklist_entry.text = "";
                show_all ();
            }
        });

        checklist_entry.changed.connect (() => {
            checklist_entry.text = Application.utils.first_letter_to_up (checklist_entry.text);
        });

        checklist_entry.focus_out_event.connect (() => {
            if (checklist_entry.text != "") {
                var row = new Widgets.CheckRow (checklist_entry.text, false);
                checklist.add (row);

                checklist_entry.text = "";
                checklist.show_all ();
            }

            return false;
        });

        note_view.focus_out_event.connect (() => {
            if (note_view.buffer.text == "") {
                note_view_placeholder_label.visible = true;
                note_view_placeholder_label.no_show_all = false;
            }

            return false;
        });

        note_view.focus_in_event.connect (() => {
            note_view_placeholder_label.visible = false;
            note_view_placeholder_label.no_show_all = true;

            return false;
        });
    }

    private bool is_repeted (int id) {
        foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
            var child = element as Widgets.LabelChild;
            if (child.label.id == id) {
                return true;
            }
        }

        return false;
    }

    private bool is_empty (Gtk.FlowBox flowbox) {
        int l = 0;
        foreach (Gtk.Widget element in flowbox.get_children ()) {
            l = l + 1;
        }

        if (l <= 0) {
            return true;
        } else {
            return false;
        }
    }

    private void add_task () {
        if (name_entry.text != "") {
            task.project_id = project_id;
            task.content = name_entry.text;
            task.note = note_view.buffer.text;

            if (is_inbox) {
                task.is_inbox = 1;
            } else {
                task.is_inbox = 0;
            }

            if (when_button.has_when) {
                task.when_date_utc = when_button.when_datetime.to_string ();
            }

            if (when_button.has_reminder) {
                task.has_reminder = 1;
                task.reminder_time = when_button.reminder_datetime.to_string ();

                // Send Notification
                string date = "";
                string time = "";

                string time_format = Granite.DateTime.get_default_time_format (true, false);
                time = when_button.reminder_datetime.format (time_format);

                if (Application.utils.is_today (when_button.when_datetime)) {
                    date = _("Today").down ();
                } else if (Application.utils.is_tomorrow (when_button.when_datetime)) {
                    date = _("Tomorrow").down ();
                } else {
                    string date_format = Granite.DateTime.get_default_date_format (false, true, false);
                    date = when_button.when_datetime.format (date_format);
                }

                Application.notification.send_local_notification (
                    task.content,
                    _("You'll be notified %s at %s".printf (date, time)),
                    "preferences-system-time",
                    5,
                    false);
            }

            foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
                var child = element as Widgets.LabelChild;
                task.labels = task.labels + child.label.id.to_string () + ";";
            }

            foreach (Gtk.Widget element in checklist.get_children ()) {
                var row = element as Widgets.CheckRow;
                task.checklist = task.checklist + row.get_check ();
            }

            if (Application.database.add_task (task) == Sqlite.DONE) {
                on_signal_close ();

                name_entry.text = "";
                note_view.buffer.text = "";
                when_button.clear ();

                foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
                    labels_flowbox.remove (element);
                }

                foreach (Gtk.Widget element in checklist.get_children ()) {
                    checklist.remove (element);
                }

                var _task = Application.database.get_last_task ();
                Application.signals.go_task_page (_task.id, _task.project_id);
            }
        }
    }
}