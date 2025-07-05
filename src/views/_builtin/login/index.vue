<script setup lang="ts">
import { computed, ref } from 'vue';
import type { Component } from 'vue';
import { mixColor } from '@sa/color';
import { loginModuleRecord } from '@/constants/app';
import { useThemeStore } from '@/store/modules/theme';
import { useRouterPush } from '@/hooks/common/router';
import LoginBgImg from '@/assets/imgs/login-bg.jpeg?url';
import pwdLoginBgSvg from '@/assets/svg-icon/pwd-login-bg.svg?url';
import codeLoginBgSvg from '@/assets/svg-icon/code-login-bg.svg?url';
import { $t } from '@/locales';
import PwdLogin from '@/views/_builtin/login/modules/pwd-login.vue';
import CodeLogin from '@/views/_builtin/login/modules/code-login.vue';

interface Props {
  /** The login module */
  module?: UnionKey.LoginModule;
}

interface LoginModule {
  label: string;
  value: string;
  component: Component;
}

// 第三方登录选项
interface ThirdPartyOption {
  key: string;
  name: string;
  icon: string;
  color: string;
  font: string;
}

const props = defineProps<Props>();
const themeStore = useThemeStore();
const { toggleLoginModule } = useRouterPush();

// ==================== 背景配置区域 ====================
// 开发者可以在此处修改背景相关配置，无需修改其他代码

/**
 * 背景配置选项
 *
 * 使用示例：
 *
 * 1. 使用默认灰色背景： defaultType: 'default'
 * 2. 使用固定自定义图片： defaultType: 'custom', customImageUrl: 'https://example.com/background.jpg'
 * 3. 使用渐变背景： defaultType: 'gradient', gradientColors: { from: '#667eea', to: '#764ba2' }
 */
const BACKGROUND_CONFIG = {
  // 默认背景类型: 'default' | 'custom' | 'gradient'
  defaultType: 'default' as UnionKey.BackgroundConfigModule,

  // 自定义背景图片URL - 当 defaultType 为 'custom' 时生效
  // 支持本地路径或网络URL，例如：'/src/assets/imgs/login-bg.jpg'
  customImageUrl: LoginBgImg,

  gradientColors: {
    from: '#667eea',
    to: '#764ba2'
  },

  // 背景遮罩配置 - 用于提高文字可读性
  overlay: {
    enabled: true, // 是否启用遮罩层 (建议在使用图片背景时开启)
    opacity: 0.3, // 遮罩透明度 (0-1，0为完全透明，1为完全不透明)
    color: '#000000' // 遮罩颜色 (通常使用黑色或深色)
  }
};

// ==================== 配置说明 ====================
// 注意事项：
// 1. 修改配置后需要重新启动开发服务器或刷新页面
// 2. 自定义图片建议使用高质量图片，分辨率至少 1920x1080
// 3. 渐变背景可以创建现代化的视觉效果
// 4. 遮罩层有助于确保登录表单的可读性
// ==================== 配置区域结束 ====================

// 背景相关状态
const backgroundType = ref(BACKGROUND_CONFIG.defaultType);
const customBackgroundUrl = ref(BACKGROUND_CONFIG.customImageUrl);
const thirdPartyOptions: ThirdPartyOption[] = [
  {
    key: 'wechat',
    name: '微信',
    icon: 'uiw:weixin',
    color: '#07c160',
    font: '25px'
  },
  {
    key: 'qq',
    name: 'QQ',
    icon: 'mdi:qqchat',
    color: '#1296db',
    font: '25px'
  },
  {
    key: 'alipay',
    name: 'Alipay',
    icon: 'tdesign:logo-alipay-filled',
    color: '#1296db',
    font: '25px'
  },
  {
    key: 'github',
    name: 'GitHub',
    icon: 'mdi:github',
    color: '#333333',
    font: '25px'
  }
];
// 渐变背景色
const gradientBg = computed(() => {
  const primaryColor = themeStore.themeColor;
  return `linear-gradient(135deg, ${primaryColor} 0%, ${primaryColor}dd 100%)`;
});
// 定义CSS样式类型
type CSSStyleObject = {
  [key: string]: string | number;
};
const backgroundStyleDefault = computed((): CSSStyleObject => {
  return themeStore.darkMode
    ? {
        '--un-bg-opacity': 1,
        backgroundColor: 'rgb(17 24 39 / var(--un-bg-opacity))'
      }
    : {
        '--tw-bg-opacity': 1,
        backgroundColor: 'rgb(229 231 235 / var(--tw-bg-opacity, 1))'
      };
});

// 计算背景样式
const backgroundStyle = computed((): CSSStyleObject => {
  switch (backgroundType.value) {
    case 'custom':
      return customBackgroundUrl.value
        ? {
            backgroundImage: `url(${customBackgroundUrl.value})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
            backgroundRepeat: 'no-repeat'
          }
        : backgroundStyleDefault.value;
    case 'gradient':
      return {
        background: `linear-gradient(135deg, ${BACKGROUND_CONFIG.gradientColors.from} 0%, ${BACKGROUND_CONFIG.gradientColors.to} 100%)`
      };
    default:
      return backgroundStyleDefault.value;
  }
});
// 计算几何图形样式 - 根据背景类型和主题自适应
const geometricShapeStyle = computed(() => {
  const isDarkTheme = themeStore.themeScheme === 'dark';
  const isDefaultBackground = backgroundType.value === 'default';

  if (isDefaultBackground) {
    // 默认背景下，根据主题调整颜色，使用mixColor函数生成
    const baseColor = isDarkTheme ? '#1f2937' : '#111827'; // gray-800 : gray-900
    const transparentColor = '#ffffff';

    return {
      borderColor: mixColor(baseColor, transparentColor, isDarkTheme ? 0.6 : 0.5), // 混合生成边框颜色
      backgroundColor: mixColor(baseColor, transparentColor, 0.7) // 混合生成背景颜色
    };
  }
  // 其他背景类型保持白色，确保在各种背景下都可见
  const whiteColor = '#ffffff';
  const transparentColor = '#000000';

  return {
    borderColor: mixColor(whiteColor, transparentColor, 0.4), // 生成60%透明度的白色
    backgroundColor: mixColor(whiteColor, transparentColor, 0.8) // 生成20%透明度的白色
  };
});
// 计算右侧登录区域背景样式
const loginAreaStyle = computed(() => {
  const isDarkTheme = themeStore.themeScheme === 'dark';

  if (isDarkTheme) {
    // 暗色模式下保持默认（透明）
    return {
      backgroundColor: 'transparent'
    };
  }
  // 亮色模式下设置为白色
  return {
    backgroundColor: '#ffffff'
  };
});

// ==================== 背景配置区域结束 ====================
const moduleMap: Record<UnionKey.LoginModule, LoginModule> = {
  'pwd-login': {
    label: loginModuleRecord['pwd-login'],
    value: 'pwd-login',
    component: PwdLogin
  },
  'code-login': {
    label: loginModuleRecord['code-login'],
    value: 'code-login',
    component: CodeLogin
  }
};
const activeModule = computed(() => moduleMap[props.module || 'pwd-login']);
const loginBgSvg = computed(() => {
  return props.module === 'code-login' ? codeLoginBgSvg : pwdLoginBgSvg;
});

// 处理第三方登录
function handleThirdPartyLogin(provider: string) {
  window.$message?.info(`第三方登录: ${provider}`);
  // 这里可以添加具体的第三方登录逻辑
}
</script>

<template>
  <div class="relative min-h-screen min-w-screen flex items-center justify-center px-5 py-5" :style="backgroundStyle">
    <!-- 背景遮罩层 - 可通过 BACKGROUND_CONFIG.overlay 配置 -->
    <div
      v-if="BACKGROUND_CONFIG.overlay.enabled && backgroundType !== 'default'"
      class="absolute inset-0"
      :style="{
        backgroundColor: BACKGROUND_CONFIG.overlay.color,
        opacity: BACKGROUND_CONFIG.overlay.opacity
      }"
    ></div>
    <div class="w-full max-w-screen-lg overflow-hidden rounded-3xl bg-gray-100 text-gray-500 shadow-xl">
      <div class="w-full md:flex">
        <!-- 左侧品牌展示区域 -->
        <div class="hidden w-1/2 px-10 py-10 md:block" :style="{ background: gradientBg }">
          <!-- 装饰性几何图形 -->
          <div class="absolute inset-0 opacity-10">
            <div
              class="absolute left-20 top-20 h-32 w-32 border-2 rounded-full"
              :style="{ borderColor: geometricShapeStyle.borderColor }"
            ></div>
            <div
              class="absolute right-32 top-40 h-24 w-24 rotate-45 transform border-2"
              :style="{ borderColor: geometricShapeStyle.borderColor }"
            ></div>
            <div
              class="absolute bottom-32 left-32 h-20 w-20 rotate-12 transform rounded-lg"
              :style="{ backgroundColor: geometricShapeStyle.backgroundColor }"
            ></div>
            <div
              class="absolute bottom-20 right-20 h-16 w-16 border-2 rounded-full"
              :style="{ borderColor: geometricShapeStyle.borderColor }"
            ></div>
          </div>

          <!-- 品牌内容 -->
          <div class="relative z-10 h-full flex flex-col items-center justify-center text-white">
            <div class="max-w-md text-center">
              <SystemLogo class="mx-auto mb-8 text-8xl" />
              <h1 class="mb-6 text-4xl font-bold">{{ $t('system.title') }}</h1>
              <div class="mb-6">
                <img :src="loginBgSvg" alt="Login Background" class="mx-auto" />
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧登录区域 -->
        <div class="w-full px-5 py-10 md:w-1/2 md:px-10" :style="loginAreaStyle">
          <!-- 移动端Logo -->
          <div class="mb-8 text-center md:hidden">
            <SystemLogo class="mx-auto mb-4 text-6xl text-primary" />
            <h2 class="text-2xl text-gray-900 font-bold">
              {{ $t('system.title') }}
            </h2>
          </div>

          <!-- 登录标题 -->
          <div class="mb-10 text-center">
            <h1 class="mb-2 text-3xl text-gray-900 font-bold">
              {{ $t(activeModule.label) }}
            </h1>
          </div>

          <!-- 登录方式切换 -->
          <div class="mb-6">
            <NTabs v-model:value="activeModule.value" type="segment" size="large" class="w-full">
              <NTab
                v-for="(item, key) in moduleMap"
                :key="key"
                :name="item.value"
                @click="toggleLoginModule(item.value as 'pwd-login' | 'code-login')"
              >
                {{ $t(item.label) }}
              </NTab>
            </NTabs>
          </div>

          <!-- 表单容器 - 固定高度确保切换时布局稳定 -->
          <div>
            <Transition :name="themeStore.page.animateMode" mode="out-in" appear>
              <component :is="activeModule.component" />
            </Transition>
          </div>

          <!-- 第三方登录 -->
          <div class="mt-8">
            <NDivider class="text-sm !text-gray-400">
              {{ $t('page.login.pwdLogin.otherLoginMode') }}
            </NDivider>

            <div class="mt-6 flex justify-center space-x-4">
              <NButton
                v-for="option in thirdPartyOptions"
                :key="option.key"
                quaternary
                circle
                size="large"
                class="!h-12 !w-12"
                @click="handleThirdPartyLogin(option.key)"
              >
                <SvgIcon :icon="option.icon" :style="{ color: option.color, fontSize: option.font }" />
              </NButton>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
