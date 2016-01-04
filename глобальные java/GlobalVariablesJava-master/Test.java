package com.arlib.floatingsearchviewdemo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.graphics.Palette;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.arlib.floatingsearchview.FloatingSearchView;
import com.arlib.floatingsearchview.suggestions.model.SearchSuggestion;
import com.arlib.floatingsearchviewdemo.data.ColorSuggestion;
import com.arlib.floatingsearchviewdemo.data.DataHelper;

import java.util.List;


// !Added by me!
public class MyPublicData {
    public static String appName = "Global Variables Metrics for Java";
    public static int version = 1;


/* string="OH MY GOD */ 
str = " /* "; 
void MethodBlabla()
{
MyPublicData.appName = "WTF is going on??!";
 MyPublicData.version = 3;
}
public class AnyClass {
    public static String SomeString = "It’s all right!";
    public static int SomeInt = 20;

/* Are you sure , man?"; */

    public static void MethodInData() {
        ClassNamedAForNoReason.someIntWalkingAround = 20;
        ClassNamedAForNoReason.someIntWalkingAround = 30;
        ClassNamedAForNoReason.ClassBNestedInA.nestedString = "YAY!";
    }
}

class ClassNamedAForNoReason {
    public static int someIntWalkingAround = 10;
    // Testing one-line comment: public static int anotherIntWalkingAround;
    void SomeRandomMethod()
    {
        MyPublicData.appName = "Why do you change me?";
        MyPublicData.version = 2;
    }

    void AnotherRandomMethod()
    {
        MyPublicData.appName = "WTF is going on??!";
        MyPublicData.version = 3;
    }
    /*
    Testing multi-line comment: public static string randomString = "I'm in a comment )";
    */

    void ThirdShittyMethod()
    {
        MyPublicData.appName = "Really? Maybe you'll stop?";
        MyPublicData.version = 5;
    }

    void FifthMethodForNoReason()
    {
        MyPublicData.appName = "Why there is no version 4?";
        MyPublicData.version = 6;
    }

    void SixthMethod()
    {
        MyPublicData.appName = "Testing strings: MyPublicData.version = 7;"
    }

    public static class ClassBNestedInA {
        public static String nestedString = "Yea";
    }
}
// End of Added by me!!

public class MainActivity extends AppCompatActivity {

    private final String TAG = "MainActivity";

    private FloatingSearchView mSearchView;

    private ViewGroup mParentView;
    private TextView mColorNameText;
    private TextView mColorValueText;

    private DrawerLayout mDrawerLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mParentView = (ViewGroup)findViewById(R.id.parent_view);

        mSearchView = (FloatingSearchView)findViewById(R.id.floating_search_view);
        mColorNameText = (TextView)findViewById(R.id.color_name_text);
        mColorValueText = (TextView)findViewById(R.id.color_value_text);

        mDrawerLayout = (DrawerLayout)findViewById(R.id.drawer_layout);

        //sets the background color
        refreshBackgroundColor("Blue", "#1976D2");

        mSearchView.setOnQueryChangeListener(new FloatingSearchView.OnQueryChangeListener() {
            @Override
            public void onSearchTextChanged(String oldQuery, final String newQuery) {

                if (!oldQuery.equals("") && newQuery.equals("")) {
                    mSearchView.clearSuggestions();
                } else {

                    //this shows the top left circular progress
                    //you can call it where ever you want, but
                    //it makes sense to do it when loading something in
                    //the background.
                    mSearchView.showProgress();

                    //simulates a query call to a data source
                    //with a new query.
                    DataHelper.find(MainActivity.this, newQuery, new DataHelper.OnFindResultsListener() {

                        @Override
                        public void onResults(List<ColorSuggestion> results) {

                            //this will swap the data and
                            //render the collapse/expand animations as necessary
                            mSearchView.swapSuggestions(results);

                            //let the users know that the background
                            //process has completed
                            mSearchView.hideProgress();
                        }
                    });
                }

                Log.d(TAG, "onSearchTextChanged()");
            }
        });

        mSearchView.setOnSearchListener(new FloatingSearchView.OnSearchListener() {
            @Override
            public void onSuggestionClicked(SearchSuggestion searchSuggestion) {

                ColorSuggestion colorSuggestion = (ColorSuggestion) searchSuggestion;
                refreshBackgroundColor(colorSuggestion.getColor().getName(), colorSuggestion.getColor().getHex());

                Log.d(TAG, "onSuggestionClicked()");
            }

            @Override
            public void onSearchAction() {

                Log.d(TAG, "onSearchAction()");
            }
        });

        mSearchView.setOnFocusChangeListener(new FloatingSearchView.OnFocusChangeListener() {
            @Override
            public void onFocus() {

                mSearchView.swapSuggestions(DataHelper.getHistory(MainActivity.this, 3));

                Log.d(TAG, "onFocus()");
            }

            @Override
            public void onFocusCleared() {

                Log.d(TAG, "onFocusCleared()");
            }
        });

        //handle menu clicks the same way as you would
        //in a regular activity
        mSearchView.setOnMenuItemClickListener(new FloatingSearchView.OnMenuItemClickListener() {
            @Override
            public void onMenuItemSelected(MenuItem item) {

                switch (item.getItemId()) {
                    case R.id.action_show_menu:
                        mSearchView.setLeftShowMenu(true);
                        break;
                    case R.id.action_hide_menu:
                        mSearchView.setLeftShowMenu(false);
                        break;
                }
            }
        });

        mSearchView.setOnLeftMenuClickListener(new FloatingSearchView.OnLeftMenuClickListener() {
            @Override
            public void onMenuOpened() {

                mDrawerLayout.openDrawer(GravityCompat.START);
            }

            @Override
            public void onMenuClosed() {
                mDrawerLayout.closeDrawer(GravityCompat.START);
            }
        });

        mDrawerLayout.setDrawerListener(new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {}

            @Override
            public void onDrawerOpened(View drawerView) {

                //since the drawer might have opened as a results of
                //a click on the left menu, we need to make sure
                //to close it right after the drawer opens, so that
                //it is closed when the drawer is  closed.
                mSearchView.closeMenu(false);
            }

            @Override
            public void onDrawerClosed(View drawerView) { }

            @Override
            public void onDrawerStateChanged(int newState) { }
        });

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        //this is needed in order for voice recognition to work
        mSearchView.onHostActivityResult(requestCode, resultCode, data);
    }

    private void refreshBackgroundColor(String colorName, String colorValue){

        int color = Color.parseColor(colorValue);
        Palette.Swatch swatch = new Palette.Swatch(color, 0);

        mColorNameText.setTextColor(swatch.getTitleTextColor());
        mColorNameText.setText(colorName);

        mColorValueText.setTextColor(swatch.getBodyTextColor());
        mColorValueText.setText(colorValue);

        mParentView.setBackgroundColor(color);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP)
            getWindow().setStatusBarColor(getDarkerColor(color, .8f));

    }

    private static int getDarkerColor(int color, float factor) {

        int a = Color.alpha(color);
        int r = Color.red(color);
        int g = Color.green(color);
        int b = Color.blue(color);

        return Color.argb(a, Math.max((int)(r * factor), 0), Math.max((int)(g * factor), 0),
                Math.max((int)(b * factor), 0));
    }

}
