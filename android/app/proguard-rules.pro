# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#**************************************************************************
#基本设置

#代码混淆压缩比例,0~7,默认5
-optimizationpasses 5
#不使用大小写混合,统一用小写
-dontusemixedcaseclassnames
#不忽略非公共的库的类和成员
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
#不做预校验
-dontpreverify
#生成映射文件,并打印
-verbose
-printusage shrinklist.txt
-printmapping pMapping.txt
#混淆时使用的算法,默认使用谷歌推荐如下
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
#避免混淆Annotation
-keepattributes *Annotation*
#避免混淆异常、内部类,泛型
-keepattributes Exceptions,InnerClasses,Signature
#抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
#****************************************************************************

#常用设置
#native方法不混淆
-keepclasseswithmembernames class * {
        native <methods>;
}
#四大组件的保留,以及View等
-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class com.android.vending.licensing.ILicensingService


#针对v4\v7包
#-dontwarn android.support.**
-keep class android.support.** { *; }
-keep interface android.support.** { *; }

#保留Activity中方法参数是 View 的方法
-keepclassmembers class * extends android.app.Activity{
        public void * (android.view.View);
}

#Parcelable序列化不被混淆
-keep class * implements android.os.Parcelable

#Serializable序列化不被混淆
-keepclassmembers class * implements java.io.Serializable {
        static final long serialVersionUID;
        private static final java.io.ObjectStreamField[] serialPersistentFields;
        private void writeObject(java.io.ObjectOutputStream);
        private void readObject(java.io.ObjectInputStream);
        java.lang.Object writeReplace();
        java.lang.Object readResolve();
}
#保留枚举类
-keep enum * { *; }

#保留自定义控件不被混淆
-keep public class * extends android.view.View{
        *** get*();
        void set*(***);
        public <init>(android.content.Context);
        public <init>(android.content.Context , android.util.AttributeSet);
        public <init>(android.content.Context , android.util.AttributeSet , int );
}

#Parcelable序列化不被混淆
-keep class * implements android.os.Parcelable

#对于资源R
-keep public class **.R$*{ *;}

#第三方的处理:
#****************网络库*****************************************************
#-dontwarn okhttp3.**
#-dontnote okhttp3.**
#-keep class okhttp3.** { *; }
#-keep interface okhttp3.** { *; }
#-keep class org.apache.commons.** { *; }
#-dontwarn org.apache.commons.**
#
#-dontwarn okio.**
#-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
#-keep class org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement{*;}
-dontwarn okio.**
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.ParametersAreNonnullByDefault

#webView:
-keepclassmembers class fqcn.of.javascript.interface.for.webview {
    public *;
}
-keepclassmembers class * {
      @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.webkit.WebChromeClient {
     public void openFileChooser(...);
}
-keepclassmembers class * extends android.webkit.webViewClient {
        public void *(android.webkit.WebView , java.lang.String , android.graphics.Bitmap);
        public boolean *(android.webkit.WebView , java.lang.String );
        public void *(android.webkit.WebView , java.lang.String );
}

#glide
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
# for DexGuard only
#-keepresourcexmlelements manifest/application/meta-data@value=GlideModule

#umeng
-keep class com.umeng.** {*;}
-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

##---------------Begin: proguard configuration for Gson  ----------
# Adapted from https://code.google.com/p/google-gson/source/browse/trunk/examples/android-proguard-example/proguard.cfg
#
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# We use Gson's @SerializedName annotation which won't work without this:
-keepattributes *Annotation*

# Gson specific classes
#-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }

# Classes that will be serialized/deserialized over Gson
# http://stackoverflow.com/a/7112371/56285
-keep class fi.company.project.models.json.** { *; }
-keep class com.google.gson.** { *; }


# support R8
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

##---------------End: proguard configuration for Gson  ----------

-dontwarn javax.annotation.**
-dontwarn javax.naming.**

# ------------------- TEST DEPENDENCIES -------------------
-dontwarn org.hamcrest.**
-dontwarn android.test.**
-dontwarn android.support.test.**

-keep class org.hamcrest.** {
   *;
}

-keep class org.junit.** { *; }
-dontwarn org.junit.**

-keep class junit.** { *; }
-dontwarn junit.**

-keep class sun.misc.** { *; }
-dontwarn sun.misc.**


-dontwarn org.codehaus.**
-dontwarn java.nio.**
-dontwarn java.lang.invoke.**
-dontwarn rx.**

#保留模型  不然json解析出错
-keep class org.maprich.app.**.entity.** {*;}
-keep class org.maprich.app.**.model.** {*;}
-keep class org.maprich.app.**.vo.** {*;}

# Retrofit2
-dontnote retrofit2.Platform
-dontwarn retrofit2.Platform$Java8

-keep class java.awt.** {*;}
-dontwarn java.awt.**

-keep class org.locationtech.** {*;}

-keep class com.alipay.** {*;}
-dontwarn com.alipay.**

-keep class com.just.agentweb.** {*;}
-dontwarn com.just.agentweb.**

-keep class com.mapbox.** {*;}
-dontwarn com.mapbox.**

-keep class org.spongycastle.** {*;}

-keep class com.mapbox.**.models.** {*;}



# Retrofit2 offical  proguard

# Retrofit does reflection on generic parameters. InnerClasses is required to use Signature and
# EnclosingMethod is required to use InnerClasses.
-keepattributes Signature, InnerClasses, EnclosingMethod

# Retrofit does reflection on method and parameter annotations.
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations

# Retain service method parameters when optimizing.
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

# Ignore annotation used for build tooling.
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement

# Ignore JSR 305 annotations for embedding nullability information.
-dontwarn javax.annotation.**

# Guarded by a NoClassDefFoundError try/catch and only used when on the classpath.
-dontwarn kotlin.Unit

# Top-level functions that can only be used by Kotlin.
-dontwarn retrofit2.KotlinExtensions

# With R8 full mode, it sees no subtypes of Retrofit interfaces since they are created with a Proxy
# and replaces all potential values with null. Explicitly keeping the interfaces prevents this.
-if interface * { @retrofit2.http.* <methods>; }
-keep,allowobfuscation interface <1>

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

#bugly
-dontwarn com.tencent.bugly.**
-keep public class com.tencent.bugly.**{*;}