module OpenVR.Internal where


import GHC.Generics (Generic)
import System.IO
import Control.Monad
import Data.Kind
import Data.Proxy
import Data.Word
import Data.Type.Equality
import System.Posix.DynamicLinker
import Foreign
import Foreign.Ptr
import Foreign.C
import Linear
import Control.Lens
import Data.Coerce
import Data.Set (Set)
import qualified Data.Set as S

#include <openvr_capi_fixed.h>
#include <util.h>


--  This code is from C2HS, but it has been added
--  here since C2HS is deprecated.
cFromEnum :: (Enum e, Integral i) => e -> i
cFromEnum  = fromIntegral . fromEnum

peekEnum :: (Enum a, Integral b, Storable b) => Ptr b -> IO a
peekEnum  = liftM (toEnum . fromIntegral) . peek
 
 
{#enum EVREye {}
 with prefix="EVREye" deriving (Show, Eq)#}
{#enum ETextureType {}
 with prefix="ETextureType" deriving (Show, Eq)#}
{#enum EColorSpace {}
  with prefix="EColorSpace" deriving (Show, Eq)#}
{#enum ETrackingResult {}
  with prefix="ETrackingResult" deriving (Show, Eq)#}
{#enum ETrackedDeviceClass {}
  with prefix="ETrackedDeviceClass" deriving (Show, Eq) #}
{#enum ETrackedControllerRole {}
  with prefix="ETrackedControllerRole" deriving (Show, Eq) #}
{#enum ETrackingUniverseOrigin {}
  with prefix="ETrackingUniverseOrigin" deriving (Show, Eq) #}
--TODO: this needs the same treatment as VREventType
{#enum ETrackedDeviceProperty {}
  with prefix="ETrackedDeviceProperty" deriving (Show, Eq) #}

{#enum ETrackedPropertyError {}
  with prefix="ETrackedPropertyError" deriving (Show, Eq) #}
{#enum EVRSubmitFlags {}
 with prefix="EVRSubmitFlags" deriving (Show, Eq)#}
{#enum EVRState {}
  with prefix="EVRState" deriving (Show, Eq) #}
{#enum EVREventType {}
 with prefix = "EVREventType" deriving (Show, Eq, Bounded)#}

allVREventTypes :: Set CUInt
allVREventTypes = S.fromList $ map (fromIntegral . fromEnum) ([minBound .. maxBound] :: [EVREventType])

data VREventType
  = KnownEvent EVREventType
  | UnknownEvent CUInt 
  deriving (Show, Eq)

instance Storable VREventType where
  sizeOf _ = sizeOf (undefined :: CUInt)
  alignment _ = alignment (undefined :: CUInt)
  peek ptr = do
    evid <- peek (castPtr ptr) :: IO CUInt
    if evid `S.member` allVREventTypes
      then return . KnownEvent .toEnum $ fromIntegral evid
      else return $ UnknownEvent evid
  poke ptr (KnownEvent ev) = poke ptr (UnknownEvent . fromIntegral $ fromEnum ev)
  poke ptr (UnknownEvent ev) = poke (castPtr ptr) ev


{#enum EDeviceActivityLevel {}
  with prefix="EDeviceActivityLevel_k" deriving (Show, Eq) #}
{#enum EVRButtonId {}
 with prefix = "EVRButtonId_k" deriving (Show, Eq)#}
{#enum EVRMouseButton {}
  with prefix="EVRMouseButton" deriving (Show, Eq) #}
{#enum EHiddenAreaMeshType {upcaseFirstLetter}
  with prefix="EHiddenAreaMeshType_k" deriving (Show, Eq) #}
{#enum EVRControllerAxisType {upcaseFirstLetter}
  with prefix="EVRControllerAxisType_k" deriving (Show, Eq) #}
{#enum EVRControllerEventOutputType {}
  with prefix="EVRControllerEventOutputType" deriving (Show, Eq) #}
{#enum ECollisionBoundsStyle {}
  with prefix="ECollisionBoundsStyle" deriving (Show, Eq) #}
{#enum EVROverlayError {}
  with prefix="EVROverlayError" deriving (Show, Eq) #}
{#enum EVRApplicationType {}
  with prefix="EVRApplicationType" deriving (Show, Eq)#}
{#enum EVRFirmwareError {}
  with prefix="EVRFirmwareError" deriving (Show, Eq) #}
{#enum EVRNotificationError {}
  with prefix="EVRNotificationError" deriving (Show, Eq) #}
{#enum EVRInitError {}
  with prefix="EVRInitError" deriving (Show, Eq)#}
{#enum EVRScreenshotType {}
  with prefix="EVRScreenshotType" deriving (Show, Eq) #}
{#enum EVRScreenshotPropertyFilenames {}
  with prefix="EVRScreenshotPropertyFilenames" deriving (Show, Eq) #}
{#enum EVRTrackedCameraError {}
  with prefix="EVRTrackedCameraError" deriving (Show, Eq) #}
{#enum EVRTrackedCameraFrameType {}
  with prefix="EVRTrackedCameraFrameType" deriving (Show, Eq) #}
{#enum EVRApplicationError {}
  with prefix="EVRApplicationError" deriving (Show, Eq) #}
{#enum EVRApplicationProperty {}
  with prefix="EVRApplicationProperty" deriving (Show, Eq) #}
{#enum EVRApplicationTransitionState {}
  with prefix="EVRApplicationTransitionState" deriving (Show, Eq) #}
{#enum ChaperoneCalibrationState {}
  with prefix="ChaperoneCalibrationState" deriving (Show, Eq) #}
{#enum EChaperoneConfigFile {}
  with prefix="EChaperoneConfigFile" deriving (Show, Eq) #}
{#enum EChaperoneImportFlags {}
  with prefix="EChaperoneImportFlags" deriving (Show, Eq) #}
{#enum EVRCompositorError {}
 with prefix="EVRCompositorError" deriving (Show, Eq)#}
{#enum VROverlayInputMethod {} deriving (Show, Eq) #}
{#enum VROverlayTransformType {} deriving (Show, Eq) #}
{#enum VROverlayFlags {} deriving (Show, Eq) #}
{#enum VRMessageOverlayResponse {} deriving (Show, Eq) #}
{#enum EGamepadTextInputMode {}
  with prefix="EGamepadTextInputMode_k" deriving (Show, Eq) #}
{#enum EGamepadTextInputLineMode {}
  with prefix="EGamepadTextInputLineMode_k" deriving (Show, Eq) #}
{#enum EOverlayDirection {}
  with prefix="EOverlayDirection" deriving (Show, Eq) #}
{#enum EVROverlayIntersectionMaskPrimitiveType {}
  with prefix="EVROverlayIntersectionMaskPrimitiveType" deriving (Show, Eq) #}
{#enum EVRRenderModelError {}
 with prefix="EVRRenderModelError" deriving (Show, Eq)#}
{#enum EVRComponentProperty {}
  with prefix="EVRComponentProperty" deriving (Show, Eq) #}
{#enum EVRNotificationType {} deriving (Show, Eq) #}
{#enum EVRNotificationStyle {} deriving (Show, Eq) #}
{#enum EVRSettingsError {}
  with prefix="EVRSettingsError" deriving (Show, Eq) #}
{#enum EVRScreenshotError {}
  with prefix="EVRScreenshotError" deriving (Show, Eq) #}

type PropertyContainerHandle_t = {#type PropertyContainerHandle_t#}
{#typedef PropertyContainerHandle_t PropertyContainerHandle_t#}

type PropertyTypeTag_t = {#type PropertyTypeTag_t#}
{#typedef PropertyTypeTag_t PropertyTypeTag_t#}

--type VRActionHandle_t = {#type VRActionHandle_t#}
--{#typedef VRActionHandle_t VRActionHandle_t #}

--type VRActionSetHandle_t = {#type VRActionSetHandle_t#}
--{#typedef VRActionSetHandle_t VRActionSetHandle_t#}

--type VRInputOriginHandle_t = {#type VRInputOriginHandle_t#}
--{#typedef VRInputOriginHandle_t VRInputOriginHandle_t#}

-- {#pointer glSharedTextureHandle_t as GlSharedTextureHandle_t newtype#}
-- deriving instance Eq GlSharedTextureHandle_t
--deriving instance Storable GlSharedTextureHandle_t

type GlSharedTextureHandle = {#type glSharedTextureHandle_t#}
-- {#typedef glSharedTextureHandle_t GlSharedTextureHandle#}

type GlInt_t = {#type glInt_t#}
{#typedef glInt_t GlInt_t#}

type GlUInt_t = {#type glUInt_t#}
{#typedef glUInt_t GlUInt_t#}

type SharedTextureHandle_t = {#type SharedTextureHandle_t#}
{#typedef SharedTextureHandle_t SharedTextureHandle_t#}

type DriverId_t = {#type DriverId_t#}
{#typedef DriverId_t DriverId_t#}

type TrackedDeviceIndex = {#type TrackedDeviceIndex_t#}
{#typedef TrackedDeviceIndex_t TrackedDeviceIndex #}

type VROverlayHandle_t = {#type VROverlayHandle_t#}
{#typedef VROverlayHandle_t VROverlayHandle_t#}

type TrackedCameraHandle_t = {#type TrackedCameraHandle_t#}
{#typedef TrackedCameraHandle_t TrackedCameraHandle_t#}

type ScreenshotHandle_t = {#type ScreenshotHandle_t#}
{#typedef ScreenshotHandle_t ScreenshotHandle_t#}

type VRComponentProperties = {#type VRComponentProperties#}
{#typedef VRComponentProperties VRComponentProperties#}

type TextureID = {#type TextureID_t#}
{#typedef TextureID_t TextureID #}

type VRNotificationId = {#type VRNotificationId#}
{#typedef VRNotificationId VRNotificationId#}

-- enum typedefs
type HmdError               = EVRInitError
type HMD_Eye                = EVREye
type ColorSpace             = EColorSpace
type HmdTrackingResult      = ETrackingResult
type TrackedDeviceClass     = ETrackedDeviceClass
type TrackingUniverseOrigin = ETrackingUniverseOrigin
type TrackedPropertyError   = ETrackedPropertyError
type VRSubmitFlags_t        = EVRSubmitFlags
type VRState_t              = EVRState
type CollisionBoundsStyle_t = ECollisionBoundsStyle
type VROverlayError         = EVROverlayError
type VRFirmwareError        = EVRFirmwareError
type VRCompositorError      = EVRCompositorError
type VRScreenshotsError     = EVRScreenshotError

-- typedef structs
{#pointer *HmdMatrix34_t as HmdMatrix34Ptr -> M34 Float #}

{#pointer *HmdMatrix44_t as HmdMatrix44Ptr -> M44 Float #}

{#pointer *HmdVector3_t as HmdVector3_t newtype#}
deriving instance Eq HmdVector3_t
deriving instance Storable HmdVector3_t

{#pointer *HmdVector4_t as HmdVector4_t newtype#}
deriving instance Eq HmdVector4_t
deriving instance Storable HmdVector4_t

{#pointer *HmdVector3d_t as HmdVector3d_t newtype#}
deriving instance Eq HmdVector3d_t
deriving instance Storable HmdVector3d_t

{#pointer *HmdVector2_t as HmdVector2_t newtype#}
deriving instance Eq HmdVector2_t
deriving instance Storable HmdVector2_t

{#pointer *HmdQuaternion_t as HmdQuaternion_t newtype#}
deriving instance Eq HmdQuaternion_t
deriving instance Storable HmdQuaternion_t

{#pointer *HmdColor_t as HmdColorPtr -> V4 Float #}

{#pointer *HmdQuad_t as HmdQuad_t newtype#}
deriving instance Eq HmdQuad_t
deriving instance Storable HmdQuad_t

{#pointer *HmdRect2_t as HmdRect2_t newtype#}
deriving instance Eq HmdRect2_t
deriving instance Storable HmdRect2_t

{#pointer *DistortionCoordinates_t as DistortionCoordinates_t newtype#}
deriving instance Eq DistortionCoordinates_t
deriving instance Storable DistortionCoordinates_t

{#pointer *Texture_t as TexturePtr -> OVRTexture#}

data OVRTexture = OVRTexture {
  textureHandle :: Ptr (),
  textureType :: ETextureType,
  textureColorSpace :: EColorSpace
  } deriving Show

instance Storable OVRTexture where
  sizeOf _ = {#sizeof Texture_t#}
  alignment _ = {#alignof Texture_t#}
  peek ptr = OVRTexture <$> {#get Texture_t->handle#} ptr
                     <*> ((toEnum . fromIntegral) <$> {#get Texture_t->eType#} ptr)
                     <*> ((toEnum . fromIntegral) <$> {#get Texture_t->eColorSpace#} ptr)
  poke ptr (OVRTexture handle ty csp) = do
    {#set Texture_t->handle#} ptr handle
    {#set Texture_t->eType#} ptr (cFromEnum ty)
    {#set Texture_t->eColorSpace#} ptr (cFromEnum csp)

{#pointer *Compositor_CumulativeStats as Compositor_CumulativeStatsPtr -> OVRCompositor_CumulativeStats #}

data OVRCompositor_CumulativeStats = OVRCompositor_CumulativeStats {
    compositorStatsPid                           :: CUInt
  , compositorStatsNumFramePresents              :: CUInt
  , compositorStatsNumDroppedFrames              :: CUInt
  , compositorStatsNumReprojectedFrames          :: CUInt
  , compositorStatsNumFramePresentsOnStartup     :: CUInt
  , compositorStatsNumDroppedFramesOnStartup     :: CUInt
  , compositorStatsNumReprojectedFramesOnStartup :: CUInt
  , compositorStatsNumLoading                    :: CUInt
  , compositorStatsNumFramePresentsLoading       :: CUInt
  , compositorStatsNumDroppedFramesLoading       :: CUInt
  , compositorStatsNumReprojectedFramesLoading   :: CUInt
  , compositorStatsNumTimedOut                   :: CUInt
  , compositorStatsNumFramePresentsTimedOut      :: CUInt
  , compositorStatsNumDroppedFramesTimedOut      :: CUInt
  , compositorStatsNumReprojectedFramesTimedOut  :: CUInt
}

instance Storable OVRCompositor_CumulativeStats where
  sizeOf _    = {#sizeof Compositor_CumulativeStats#}
  alignment _ = {#alignof Compositor_CumulativeStats#}
  peek ptr =  OVRCompositor_CumulativeStats <$> ({#get Compositor_CumulativeStats->m_nPid#}                           ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumFramePresents#}              ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumDroppedFrames#}              ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumReprojectedFrames#}          ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumFramePresentsOnStartup#}     ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumDroppedFramesOnStartup#}     ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumReprojectedFramesOnStartup#} ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumLoading#}                    ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumFramePresentsLoading#}       ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumDroppedFramesLoading#}       ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumReprojectedFramesLoading#}   ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumTimedOut#}                   ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumFramePresentsTimedOut#}      ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumDroppedFramesTimedOut#}      ptr)
                                            <*> ({#get Compositor_CumulativeStats->m_nNumReprojectedFramesTimedOut#}  ptr)
  poke ptr ovrCompositor_CumulativeStats = do
    {#set Compositor_CumulativeStats->m_nPid#}                           ptr (compositorStatsPid                           ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumFramePresents#}              ptr (compositorStatsNumFramePresents              ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumDroppedFrames#}              ptr (compositorStatsNumDroppedFrames              ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumReprojectedFrames#}          ptr (compositorStatsNumReprojectedFrames          ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumFramePresentsOnStartup#}     ptr (compositorStatsNumFramePresentsOnStartup     ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumDroppedFramesOnStartup#}     ptr (compositorStatsNumDroppedFramesOnStartup     ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumReprojectedFramesOnStartup#} ptr (compositorStatsNumReprojectedFramesOnStartup ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumLoading#}                    ptr (compositorStatsNumLoading                    ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumFramePresentsLoading#}       ptr (compositorStatsNumFramePresentsLoading       ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumDroppedFramesLoading#}       ptr (compositorStatsNumDroppedFramesLoading       ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumReprojectedFramesLoading#}   ptr (compositorStatsNumReprojectedFramesLoading   ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumTimedOut#}                   ptr (compositorStatsNumTimedOut                   ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumFramePresentsTimedOut#}      ptr (compositorStatsNumFramePresentsTimedOut      ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumDroppedFramesTimedOut#}      ptr (compositorStatsNumDroppedFramesTimedOut      ovrCompositor_CumulativeStats)
    {#set Compositor_CumulativeStats->m_nNumReprojectedFramesTimedOut#}  ptr (compositorStatsNumReprojectedFramesTimedOut  ovrCompositor_CumulativeStats)

{#pointer *TrackedDevicePose_t as TrackedDevicePosePtr -> TrackedDevicePose#}

data TrackedDevicePose = TrackedDevicePose {
  poseDeviceToAbsoluteTracking :: M34 Float,
  poseVelocity :: V3 Float,
  poseAngularVelocity :: V3 Float,
  poseTrackingResult :: ETrackingResult,
  poseIsValid :: Bool,
  poseDeviceIsConnected :: Bool
  } deriving Show

instance Storable TrackedDevicePose where
  sizeOf _ = {#sizeof TrackedDevicePose_t#}
  alignment _ = {#alignof TrackedDevicePose_t#}
  peek ptr = TrackedDevicePose <$> peekByteOff ptr {#offsetof TrackedDevicePose_t->mDeviceToAbsoluteTracking #}
                               <*> peekByteOff ptr {#offsetof TrackedDevicePose_t->vVelocity #}
                               <*> peekByteOff ptr {#offsetof TrackedDevicePose_t->vAngularVelocity #}
                               <*> ((toEnum . fromIntegral) <$> {#get TrackedDevicePose_t->eTrackingResult #} ptr)
                               <*> {#get TrackedDevicePose_t->bPoseIsValid #} ptr
                               <*> {#get TrackedDevicePose_t->bDeviceIsConnected #} ptr
  poke ptr (TrackedDevicePose tf v av res valid conn) = do
    pokeByteOff ptr {#offsetof TrackedDevicePose_t->mDeviceToAbsoluteTracking #} tf 
    pokeByteOff ptr {#offsetof TrackedDevicePose_t->vVelocity #} v
    pokeByteOff ptr {#offsetof TrackedDevicePose_t->vAngularVelocity #} av
    {#set TrackedDevicePose_t->eTrackingResult #} ptr (cFromEnum res)
    {#set TrackedDevicePose_t->bPoseIsValid #} ptr valid
    {#set TrackedDevicePose_t->bDeviceIsConnected #} ptr conn


data VRTextureBounds = VRTextureBounds CFloat CFloat CFloat CFloat
{#pointer *VRTextureBounds_t as VRTextureBounds_t -> VRTextureBounds#}

instance Storable VRTextureBounds where
  sizeOf _ = {#sizeof VRTextureBounds_t#}
  alignment _ = {#alignof VRTextureBounds_t#}
  peek ptr = VRTextureBounds <$> {#get VRTextureBounds_t->uMin#} ptr
                               <*> {#get VRTextureBounds_t->vMin#} ptr
                               <*> {#get VRTextureBounds_t->uMax#} ptr
                               <*> {#get VRTextureBounds_t->vMax#} ptr
  poke ptr (VRTextureBounds uMin vMin uMax vMax) = do
    {#set VRTextureBounds_t->uMin#} ptr uMin
    {#set VRTextureBounds_t->vMin#} ptr vMin
    {#set VRTextureBounds_t->uMax#} ptr uMax
    {#set VRTextureBounds_t->vMax#} ptr vMax

--{#pointer *VRTextureWithPose_t as VRTextureWithPose_t newtype#}
--deriving instance Eq VRTextureWithPose_t
--deriving instance Storable VRTextureWithPose_t

data VRVulkanTextureData = VRVulkanTextureData Word64 (Ptr ()) (Ptr ()) (Ptr ()) (Ptr ()) Word32 Word32 Word32 Word32 Word32

{#pointer *VRVulkanTextureData_t as VRVulkanTextureData_t -> VRVulkanTextureData#}

instance Storable VRVulkanTextureData where
  sizeOf _ = {#sizeof VRVulkanTextureData_t#}
  alignment _ = {#alignof VRVulkanTextureData_t#}
  peek ptr = VRVulkanTextureData <$> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nImage #} ptr)
                                 <*> {#get VRVulkanTextureData_t->m_pDevice #} ptr
                                 <*> {#get VRVulkanTextureData_t->m_pPhysicalDevice #} ptr
                                 <*> {#get VRVulkanTextureData_t->m_pInstance #} ptr
                                 <*> {#get VRVulkanTextureData_t->m_pQueue #} ptr
                                 <*> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nQueueFamilyIndex #} ptr)
                                 <*> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nWidth #} ptr)
                                 <*> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nHeight #} ptr)
                                 <*> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nFormat #} ptr)
                                 <*> (fromIntegral <$> {#get VRVulkanTextureData_t->m_nSampleCount #} ptr)
  poke ptr (VRVulkanTextureData image dev phys inst queue idx w h fmt smp) = do
    {#set VRVulkanTextureData_t->m_nImage #} ptr (fromIntegral image)
    {#set VRVulkanTextureData_t->m_pDevice #} ptr dev
    {#set VRVulkanTextureData_t->m_pPhysicalDevice #} ptr phys
    {#set VRVulkanTextureData_t->m_pInstance #} ptr inst
    {#set VRVulkanTextureData_t->m_pQueue #} ptr queue
    {#set VRVulkanTextureData_t->m_nQueueFamilyIndex #} ptr (fromIntegral idx)
    {#set VRVulkanTextureData_t->m_nWidth #} ptr (fromIntegral w)
    {#set VRVulkanTextureData_t->m_nHeight #} ptr (fromIntegral h)
    {#set VRVulkanTextureData_t->m_nFormat #} ptr (fromIntegral fmt)
    {#set VRVulkanTextureData_t->m_nSampleCount #} ptr (fromIntegral smp)

{#pointer *D3D12TextureData_t as D3D12TextureData_t newtype#}
deriving instance Eq D3D12TextureData_t
deriving instance Storable D3D12TextureData_t

{#pointer *VREvent_Mouse_t as VREvent_Mouse_t newtype#}
deriving instance Eq VREvent_Mouse_t
deriving instance Storable VREvent_Mouse_t

{#pointer *VREvent_Scroll_t as VREvent_Scroll_t newtype#}
deriving instance Eq VREvent_Scroll_t
deriving instance Storable VREvent_Scroll_t

{#pointer *VREvent_TouchPadMove_t as VREvent_TouchPadMove_t newtype#}
deriving instance Eq VREvent_TouchPadMove_t
deriving instance Storable VREvent_TouchPadMove_t

{#pointer *VREvent_Notification_t as VREvent_Notification_t newtype#}
deriving instance Eq VREvent_Notification_t
deriving instance Storable VREvent_Notification_t

{#pointer *VREvent_Process_t as VREvent_Process_t newtype#}
deriving instance Eq VREvent_Process_t
deriving instance Storable VREvent_Process_t

{#pointer *VREvent_Overlay_t as VREvent_Overlay_t newtype#}
deriving instance Eq VREvent_Overlay_t
deriving instance Storable VREvent_Overlay_t

{#pointer *VREvent_Status_t as VREvent_Status_t newtype#}
deriving instance Eq VREvent_Status_t
deriving instance Storable VREvent_Status_t

{#pointer *VREvent_Keyboard_t as VREvent_Keyboard_t newtype#}
deriving instance Eq VREvent_Keyboard_t
deriving instance Storable VREvent_Keyboard_t

{#pointer *VREvent_Ipd_t as VREvent_Ipd_t newtype#}
deriving instance Eq VREvent_Ipd_t
deriving instance Storable VREvent_Ipd_t

{#pointer *VREvent_Chaperone_t as VREvent_Chaperone_t newtype#}
deriving instance Eq VREvent_Chaperone_t
deriving instance Storable VREvent_Chaperone_t

{#pointer *VREvent_Reserved_t as VREvent_Reserved_t newtype#}
deriving instance Eq VREvent_Reserved_t
deriving instance Storable VREvent_Reserved_t

{#pointer *VREvent_PerformanceTest_t as VREvent_PerformanceTest_t newtype#}
deriving instance Eq VREvent_PerformanceTest_t
deriving instance Storable VREvent_PerformanceTest_t

{#pointer *VREvent_SeatedZeroPoseReset_t as VREvent_SeatedZeroPoseReset_t newtype#}
deriving instance Eq VREvent_SeatedZeroPoseReset_t
deriving instance Storable VREvent_SeatedZeroPoseReset_t

{#pointer *VREvent_Screenshot_t as VREvent_Screenshot_t newtype#}
deriving instance Eq VREvent_Screenshot_t
deriving instance Storable VREvent_Screenshot_t

{#pointer *VREvent_ScreenshotProgress_t as VREvent_ScreenshotProgress_t newtype#}
deriving instance Eq VREvent_ScreenshotProgress_t
deriving instance Storable VREvent_ScreenshotProgress_t

{#pointer *VREvent_ApplicationLaunch_t as VREvent_ApplicationLaunch_t newtype#}
deriving instance Eq VREvent_ApplicationLaunch_t
deriving instance Storable VREvent_ApplicationLaunch_t

{#pointer *VREvent_EditingCameraSurface_t as VREvent_EditingCameraSurface_t newtype#}
deriving instance Eq VREvent_EditingCameraSurface_t
deriving instance Storable VREvent_EditingCameraSurface_t

{#pointer *VREvent_MessageOverlay_t as VREvent_MessageOverlay_t newtype#}
deriving instance Eq VREvent_MessageOverlay_t
deriving instance Storable VREvent_MessageOverlay_t

{#pointer *VREvent_Property_t as VREvent_Property_t newtype#}
deriving instance Eq VREvent_Property_t
deriving instance Storable VREvent_Property_t

{#pointer *HiddenAreaMesh_t as HiddenAreaMesh_t newtype#}
deriving instance Eq HiddenAreaMesh_t
deriving instance Storable HiddenAreaMesh_t

{#pointer *VRControllerAxis_t as VRControllerAxis_t newtype#}
deriving instance Eq VRControllerAxis_t
deriving instance Storable VRControllerAxis_t

{#pointer *VRControllerState_t as VRControllerState_t newtype#}
deriving instance Eq VRControllerState_t
deriving instance Storable VRControllerState_t

{#pointer *Compositor_OverlaySettings as Compositor_OverlaySettings newtype#}
deriving instance Eq Compositor_OverlaySettings
deriving instance Storable Compositor_OverlaySettings

{#pointer *CameraVideoStreamFrameHeader_t as CameraVideoStreamFrameHeader_t newtype#}
deriving instance Eq CameraVideoStreamFrameHeader_t
deriving instance Storable CameraVideoStreamFrameHeader_t

{#pointer *AppOverrideKeys_t as AppOverrideKeys_t newtype#}
deriving instance Eq AppOverrideKeys_t
deriving instance Storable AppOverrideKeys_t

{#pointer *Compositor_FrameTiming as Compositor_FrameTiming newtype#}
deriving instance Eq Compositor_FrameTiming
deriving instance Storable Compositor_FrameTiming

-- {#pointer *Compositor_CumulativeStats as Compositor_CumulativeStats newtype#}
-- deriving instance Eq Compositor_CumulativeStats
-- deriving instance Storable Compositor_CumulativeStats

{#pointer *VROverlayIntersectionParams_t as VROverlayIntersectionParams_t newtype#}
deriving instance Eq VROverlayIntersectionParams_t
deriving instance Storable VROverlayIntersectionParams_t

{#pointer *VROverlayIntersectionResults_t as VROverlayIntersectionResults_t newtype#}
deriving instance Eq VROverlayIntersectionResults_t
deriving instance Storable VROverlayIntersectionResults_t

{#pointer *IntersectionMaskRectangle_t as IntersectionMaskRectangle_t newtype#}
deriving instance Eq IntersectionMaskRectangle_t
deriving instance Storable IntersectionMaskRectangle_t

{#pointer *IntersectionMaskCircle_t as IntersectionMaskCircle_t newtype#}
deriving instance Eq IntersectionMaskCircle_t
deriving instance Storable IntersectionMaskCircle_t

{#pointer *RenderModel_ComponentState_t as RenderModel_ComponentState_t newtype#}
deriving instance Eq RenderModel_ComponentState_t
deriving instance Storable RenderModel_ComponentState_t

{#pointer *RenderModel_Vertex_t as RenderModel_VertexPtr #}

sizeOfRenderModelVertex :: Integral a => a
offsetOfRenderModelVertexPosition,  offsetOfRenderModelVertexNormal
  , offsetOfRenderModelVertexTextureCoord :: Ptr ()
sizeOfRenderModelVertex = {#sizeof RenderModel_Vertex_t#}
offsetOfRenderModelVertexPosition = intPtrToPtr {#offsetof RenderModel_Vertex_t->vPosition#}
offsetOfRenderModelVertexNormal = intPtrToPtr {#offsetof RenderModel_Vertex_t->vNormal#}
offsetOfRenderModelVertexTextureCoord = intPtrToPtr {#offsetof RenderModel_Vertex_t->rfTextureCoord#}

data RenderModel_TextureMap = RenderModel_TextureMap
  { textureMapWidth :: Int
  , textureMapHeight :: Int
  , textureMapData :: Ptr CUChar
  } deriving Eq

{#pointer *RenderModel_TextureMap_t as RenderModel_TextureMapPtr -> RenderModel_TextureMap #}

-- manual instance due to c2hs not handling #pragma pack
instance Storable RenderModel_TextureMap where
  sizeOf _ = 12
  alignment _ = 4
  peek ptr = RenderModel_TextureMap
             <$> (fromIntegral <$> (peekByteOff ptr 0 :: IO CUShort))
             <*> (fromIntegral <$> (peekByteOff ptr 2 :: IO CUShort))
             <*> peekByteOff ptr 4
  poke = error "RenderModel_TextureMap poke unsupported"


data RenderModel = RenderModel
  { modelVertexData :: RenderModel_VertexPtr
  , modelVertexCount :: Int
  , modelIndexData :: Ptr CUShort
  , modelTriangleCount :: Int
  , modelDiffuseTextureId :: TextureID
  } deriving Eq
    
{#pointer *RenderModel_t as RenderModelPtr -> RenderModel #}

instance Storable RenderModel where
  sizeOf _ = 28
  alignment _ = 4
  peek ptr = RenderModel
             <$> peekByteOff ptr 0
             <*> (fromIntegral <$> (peekByteOff ptr 8 :: IO CUInt))
             <*> peekByteOff ptr 12
             <*> (fromIntegral <$> (peekByteOff ptr 20 :: IO CUInt))
             <*> peekByteOff ptr 24
  poke = error "RenderModel poke unsupported"

{#pointer *RenderModel_ControllerMode_State_t as RenderModel_ControllerMode_State_t newtype#}
deriving instance Eq RenderModel_ControllerMode_State_t
deriving instance Storable RenderModel_ControllerMode_State_t

{#pointer *NotificationBitmap_t as NotificationBitmap_t newtype#}
deriving instance Eq NotificationBitmap_t
deriving instance Storable NotificationBitmap_t

{#pointer *COpenVRContext as COpenVRContext newtype#}
deriving instance Eq COpenVRContext
deriving instance Storable COpenVRContext

-- typedef unions
data VREvent_Data
  = VREvent_Reserved CULong CULong
  | VREvent_Controller EVRButtonId
  {-
  | VREvent_Mouse VREvent_Mouse_t
  | VREvent_Scroll VREvent_Scroll_t
  | VREvent_Process VREvent_Process_t
  | VREvent_Notification VREvent_Notification_t
  | VREvent_Overlay VREvent_Overlay_t
  | VREvent_Status VREvent_Status_t
  | VREvent_Keyboard VREvent_Keyboard_t
  | VREvent_Ipd VREvent_Ipd_t
  | VREvent_Chaperone VREvent_Chaperone_t
  | VREvent_PerformanceTest VREvent_PerformanceTest_t
  | VREvent_TouchPadMove VREvent_TouchPadMove_t
  | VREvent_SeatedZeroPoseReset VREvent_SeatedZeroPoseReset_t
  | VREvent_Screenshot VREvent_Screenshot_t
  | VREvent_ScreenshotProgress VREvent_ScreenshotProgress_t
  | VREvent_ApplicationLaunch VREvent_ApplicationLaunch_t
  | VREvent_EditingCameraSurface VREvent_EditingCameraSurface_t
  | VREvent_MessageOverlay VREvent_MessageOverlay_t
  | VREvent_Property VREvent_Property_t
-}
  deriving Eq

{#pointer *VREvent_Data_t as VREvent_DataPtr -> VREvent_Data #}

--TODO remainder
peekData :: VREventType -> Ptr VREvent_Data -> IO VREvent_Data
peekData = go
  where
    go (KnownEvent VREvent_ButtonPress) = peekController
    go (KnownEvent VREvent_ButtonUnpress) = peekController
    go (KnownEvent VREvent_ButtonTouch) = peekController
    go (KnownEvent VREvent_ButtonUntouch) = peekController

    go _ = peekReserved 

    peekController ptr = VREvent_Controller . toEnum . fromIntegral
                         <$> {#get VREvent_Data_t.controller.button#} ptr
    peekReserved ptr = VREvent_Reserved
                       <$> {#get VREvent_Data_t.reserved.reserved0#} ptr
                       <*> {#get VREvent_Data_t.reserved.reserved1#} ptr

{#pointer *VROverlayIntersectionMaskPrimitive_Data_t as VROverlayIntersectionMaskPrimitive_Data_t newtype#}
deriving instance Eq VROverlayIntersectionMaskPrimitive_Data_t
deriving instance Storable VROverlayIntersectionMaskPrimitive_Data_t -- needed for unions?

-- pure structs
data VREvent = VREvent
  { eventType :: VREventType -- either out-of-range, or a known event
  , eventTrackedDeviceIndex :: TrackedDeviceIndex
  , eventAgeSeconds :: CFloat
  , eventData :: VREvent_Data
  } deriving Eq

{#pointer *VREvent_t as VREventPtr -> VREvent #}

-- god damnit Valve (pragma pack 4.)
instance Storable VREvent where
  sizeOf _ = 36
  alignment _ = 4
  peek ptr = do
    evty<- peekByteOff ptr 0
    VREvent evty
      <$> peekByteOff ptr 4
      <*> peekByteOff ptr 8
      <*> peekData evty (castPtr $ ptr `plusPtr` 12)
  poke = error "VREvent poke not supported"


{#pointer *VROverlayIntersectionMaskPrimitive_t as VROverlayIntersectionMaskPrimitive_t newtype#}
deriving instance Eq VROverlayIntersectionMaskPrimitive_t
deriving instance Storable VROverlayIntersectionMaskPrimitive_t

--pure struct function tables
{#pointer *VR_IVRSystem_FnTable as VR_IVRSystem_FnTable newtype#}
deriving instance Eq VR_IVRSystem_FnTable
deriving instance Storable VR_IVRSystem_FnTable

{#pointer *VR_IVRExtendedDisplay_FnTable as VR_IVRExtendedDisplay_FnTable newtype#}
deriving instance Eq VR_IVRExtendedDisplay_FnTable
deriving instance Storable VR_IVRExtendedDisplay_FnTable

{#pointer *VR_IVRTrackedCamera_FnTable as VR_IVRTrackedCamera_FnTable newtype#}
deriving instance Eq VR_IVRTrackedCamera_FnTable
deriving instance Storable VR_IVRTrackedCamera_FnTable

{#pointer *VR_IVRApplications_FnTable as VR_IVRApplications_FnTable newtype#}
deriving instance Eq VR_IVRApplications_FnTable
deriving instance Storable VR_IVRApplications_FnTable

{#pointer *VR_IVRChaperone_FnTable as VR_IVRChaperone_FnTable newtype#}
deriving instance Eq VR_IVRChaperone_FnTable
deriving instance Storable VR_IVRChaperone_FnTable

{#pointer *VR_IVRChaperoneSetup_FnTable as VR_IVRChaperoneSetup_FnTable newtype#}
deriving instance Eq VR_IVRChaperoneSetup_FnTable
deriving instance Storable VR_IVRChaperoneSetup_FnTable

{#pointer *VR_IVRCompositor_FnTable as VR_IVRCompositor_FnTable newtype#}
deriving instance Eq VR_IVRCompositor_FnTable
deriving instance Storable VR_IVRCompositor_FnTable

{#pointer *VR_IVROverlay_FnTable as VR_IVROverlay_FnTable newtype#}
deriving instance Eq VR_IVROverlay_FnTable
deriving instance Storable VR_IVROverlay_FnTable

{#pointer *VR_IVRRenderModels_FnTable as VR_IVRRenderModels_FnTable newtype#}
deriving instance Eq VR_IVRRenderModels_FnTable
deriving instance Storable VR_IVRRenderModels_FnTable

{#pointer *VR_IVRNotifications_FnTable as VR_IVRNotifications_FnTable newtype#}
deriving instance Eq VR_IVRNotifications_FnTable
deriving instance Storable VR_IVRNotifications_FnTable

{#pointer *VR_IVRSettings_FnTable as VR_IVRSettings_FnTable newtype#}
deriving instance Eq VR_IVRSettings_FnTable
deriving instance Storable VR_IVRSettings_FnTable

{#pointer *VR_IVRScreenshots_FnTable as VR_IVRScreenshots_FnTable newtype#}
deriving instance Eq VR_IVRScreenshots_FnTable
deriving instance Storable VR_IVRScreenshots_FnTable

{#pointer *VR_IVRResources_FnTable as VR_IVRResources_FnTable newtype#}
deriving instance Eq VR_IVRResources_FnTable
deriving instance Storable VR_IVRResources_FnTable

{#pointer *VR_IVRDriverManager_FnTable as VR_IVRDriverManager_FnTable newtype#}
deriving instance Eq VR_IVRDriverManager_FnTable
deriving instance Storable VR_IVRDriverManager_FnTable

-- global entry point functions
-- but first: two functions below make use of the `intptr_t` C type
{#typedef intptr_t IntPtr #}     -- tells c2hs to associate C type intptr_t with HS type IntPtr_t

{#fun VR_InitInternal as vrInit {alloca- `EVRInitError' peekEnum* , `EVRApplicationType'} -> `IntPtr'#}
{#fun VR_ShutdownInternal as vrShutdown {} -> `()'#}
{#fun VR_IsHmdPresent as vrIsHmdPresent {} -> `Bool'#}
{#fun VR_GetGenericInterface as vrGetGenericInterface {`String', alloca- `EVRInitError' peekEnum*} -> `IntPtr'#}

-- type-safe context stuff

-- IVRCompositor

-- virtual EVRCompositorError Submit( EVREye eEye, const Texture_t *pTexture, const VRTextureBounds_t* pBounds = 0, EVRSubmitFlags nSubmitFlags = Submit_Default ) = 0;
{#fun VR_IVRCompositor_FnTable->Submit as ivrCompositorSubmit_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `EVREye'
      , `TexturePtr'
      , `VRTextureBounds_t'
      , `EVRSubmitFlags' } -> `EVRCompositorError' #}


-- virtual EVRCompositorError WaitGetPoses( VR_ARRAY_COUNT(unRenderPoseArrayCount) TrackedDevicePose_t* pRenderPoseArray, uint32_t unRenderPoseArrayCount,
{#fun VR_IVRCompositor_FnTable->WaitGetPoses as ivrCompositorWaitGetPoses_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , id `TrackedDevicePosePtr'
      , `Int'
      , id `TrackedDevicePosePtr'
      , `Int' } -> `EVRCompositorError' #}

-- virtual uint32_t GetVulkanInstanceExtensionsRequired( VR_OUT_STRING() char *pchValue, uint32_t unBufferSize ) = 0;
{#fun VR_IVRCompositor_FnTable->GetVulkanInstanceExtensionsRequired as ivrCompositorGetVulkanInstanceExtensionsRequired_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , id `Ptr CChar'
      , `Int'} -> `Int'#}

-- virtual uint32_t GetVulkanDeviceExtensionsRequired( VkPhysicalDevice_T *pPhysicalDevice, VR_OUT_STRING() char *pchValue, uint32_t unBufferSize ) = 0;
{#fun VR_IVRCompositor_FnTable->GetVulkanDeviceExtensionsRequired as ivrCompositorGetVulkanDeviceExtensionsRequired_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , id `Ptr ()'
      , id `Ptr CChar'
      , `Int'} -> `Int'#}

-- virtual void SetTrackingSpace( ETrackingUniverseOrigin eOrigin ) = 0;
{#fun VR_IVRCompositor_FnTable->SetTrackingSpace as ivrCompositorSetTrackignSpace_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `ETrackingUniverseOrigin' } -> `()' #}

-- virtual ETrackingUniverseOrigin GetTrackingSpace() = 0;
{#fun VR_IVRCompositor_FnTable->GetTrackingSpace as ivrCompositorGetTrackignSpace_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `ETrackingUniverseOrigin' #}

--TODO: VR_ARRAY_COUNT(unGamePoseArrayCount) TrackedDevicePose_t* pGamePoseArray, uint32_t unGamePoseArrayCount ) = 0;
--TODO: virtual EVRCompositorError GetLastPoses( VR_ARRAY_COUNT( unRenderPoseArrayCount ) TrackedDevicePose_t* pRenderPoseArray, uint32_t unRenderPoseArrayCount,
--TODO: VR_ARRAY_COUNT( unGamePoseArrayCount ) TrackedDevicePose_t* pGamePoseArray, uint32_t unGamePoseArrayCount ) = 0;

-- virtual EVRCompositorError GetLastPoseForTrackedDeviceIndex( TrackedDeviceIndex_t unDeviceIndex, TrackedDevicePose_t *pOutputPose, TrackedDevicePose_t *pOutputGamePose ) = 0;
{#fun VR_IVRCompositor_FnTable->GetLastPoseForTrackedDeviceIndex as ivrCompositorGetLastPoseForTrackedDeviceIndex_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `TrackedDeviceIndex'
      , alloca- `TrackedDevicePose' peek*
      , alloca- `TrackedDevicePose' peek*} -> `EVRCompositorError' #}

--virtual void ClearLastSubmittedFrame() = 0;
{#fun VR_IVRCompositor_FnTable->ClearLastSubmittedFrame as ivrCompositorClearLastSubmittedFrame_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void PostPresentHandoff() = 0;
{#fun VR_IVRCompositor_FnTable->PostPresentHandoff as ivrCompositorPostPresentHandoff_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual bool GetFrameTiming( Compositor_FrameTiming *pTiming, uint32_t unFramesAgo = 0 ) = 0;
{#fun VR_IVRCompositor_FnTable->GetFrameTiming as ivrCompositorGetFrameTiming_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Compositor_FrameTiming'
      , `CUInt'} -> `Bool' #}

-- virtual uint32_t GetFrameTimings( Compositor_FrameTiming *pTiming, uint32_t nFrames ) = 0;
{#fun VR_IVRCompositor_FnTable->GetFrameTimings as ivrCompositorGetFrameTimings_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Compositor_FrameTiming' -- TODO: Give caller a way to retrieve [Compositor_FrameTiming]
      , `CUInt'} -> `Bool' #}


--virtual float GetFrameTimeRemaining() = 0;
{#fun VR_IVRCompositor_FnTable->GetFrameTimeRemaining as ivrCompositorGetFrameTimeRemaining_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--{#pointer *Compositor_CumulativeStats as Compositor_CumulativeStatsPtr -> OVRCompositor_CumulativeStats #}
-- virtual void GetCumulativeStats( Compositor_CumulativeStats *pStats, uint32_t nStatsSizeInBytes ) = 0;
{#fun VR_IVRCompositor_FnTable->GetCumulativeStats as ivrCompositorGetCumulativeStats_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , alloca- `OVRCompositor_CumulativeStats' peek*
      , `CUInt'} -> `()' #}

-- virtual void FadeToColor( float fSeconds, float fRed, float fGreen, float fBlue, float fAlpha, bool bBackground = false ) = 0;
{#fun VR_IVRCompositor_FnTable->FadeToColor as ivrCompositorFadeToColor_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Float'
      , `Float'
      , `Float'
      , `Float'
      , `Float'
      , `Bool'} -> `()' #}

--virtual HmdColor_t GetCurrentFadeColor( bool bBackground = false ) = 0;
{#fun VR_IVRCompositor_GetCurrentFadeColor as ivrCompositorGetCurrentFadeColor_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Bool'
      , alloca- `V4 Float' peek* } -> `()' #}

--virtual void FadeGrid( float fSeconds, bool bFadeIn ) = 0;
{#fun VR_IVRCompositor_FnTable->FadeGrid as ivrCompositorFadeGrid_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Float'
      , `Bool'} -> `()' #}

--virtual float GetCurrentGridAlpha() = 0;
{#fun VR_IVRCompositor_FnTable->GetCurrentGridAlpha as ivrCompositorGetCurrentGridAlpha_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--TODO: virtual EVRCompositorError SetSkyboxOverride( VR_ARRAY_COUNT( unTextureCount ) const Texture_t *pTextures, uint32_t unTextureCount ) = 0;

--virtual void ClearSkyboxOverride() = 0;
{#fun VR_IVRCompositor_FnTable->ClearSkyboxOverride as ivrCompositorClearSkyboxOverride_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void CompositorBringToFront() = 0;
{#fun VR_IVRCompositor_FnTable->CompositorBringToFront as ivrCompositorBringToFront_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void CompositorGoToBack() = 0;
{#fun VR_IVRCompositor_FnTable->CompositorGoToBack as ivrCompositorGoToBack_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void CompositorQuit() = 0;
{#fun VR_IVRCompositor_FnTable->CompositorQuit as ivrCompositorQuit_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual bool IsFullscreen() = 0;
{#fun VR_IVRCompositor_FnTable->IsFullscreen as ivrCompositorIsFullscreen_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual uint32_t GetCurrentSceneFocusProcess() = 0;
{#fun VR_IVRCompositor_FnTable->GetCurrentSceneFocusProcess as ivrCompositorGetCurrentSceneFocusProcess_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual uint32_t GetLastFrameRenderer() = 0;
{#fun VR_IVRCompositor_FnTable->GetLastFrameRenderer as ivrCompositorGetLastFrameRenderer_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual bool CanRenderScene() = 0;
{#fun VR_IVRCompositor_FnTable->CanRenderScene as ivrCompositorCanRenderScene_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void ShowMirrorWindow() = 0;
{#fun VR_IVRCompositor_FnTable->ShowMirrorWindow as ivrCompositorShowMirrorWindow_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void HideMirrorWindow() = 0;
{#fun VR_IVRCompositor_FnTable->HideMirrorWindow as ivrCompositorHideMirrorWindow_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual bool IsMirrorWindowVisible() = 0;
{#fun VR_IVRCompositor_FnTable->IsMirrorWindowVisible as ivrCompositorIsMirrorWindowVisible_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual void CompositorDumpImages() = 0;
{#fun VR_IVRCompositor_FnTable->CompositorDumpImages as ivrCompositorCompositorDumpImages_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

--virtual bool ShouldAppRenderWithLowResources() = 0;
{#fun VR_IVRCompositor_FnTable->ShouldAppRenderWithLowResources as ivrCompositorShouldAppRenderWithLowResources_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

-- virtual void ForceInterleavedReprojectionOn( bool bOverride ) = 0;
{#fun VR_IVRCompositor_FnTable->ForceInterleavedReprojectionOn as ivrCompositorForceInterleavedReprojectionOn_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Bool' } -> `()' #}

-- virtual void ForceReconnectProcess() = 0;
{#fun VR_IVRCompositor_FnTable->ForceReconnectProcess as ivrCompositorForceReconnectProcess_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `()' #}

-- virtual void SuspendRendering( bool bSuspend ) = 0;
{#fun VR_IVRCompositor_FnTable->SuspendRendering as ivrCompositorSuspendRendering_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Bool' } -> `()' #}

-- virtual vr::EVRCompositorError GetMirrorTextureGL( vr::EVREye eEye, vr::glUInt_t *pglTextureId, vr::glSharedTextureHandle_t *pglSharedTextureHandle ) = 0;
{#fun VR_IVRCompositor_FnTable->GetMirrorTextureGL as ivrCompositorGetMirrorTextureGL_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `EVREye'
      , id `Ptr GlUInt_t'
      , alloca- `GlSharedTextureHandle' peek* } -> `EVRCompositorError' #}

--TODO: virtual bool ReleaseSharedGLTexture( vr::glUInt_t glTextureId, vr::glSharedTextureHandle_t glSharedTextureHandle ) = 0;
-- {#fun VR_IVRCompositor_FnTable->ReleaseSharedGLTexture as ivrCompositorReleaseSharedGLTexture_
--       { coerce `VR_IVRCompositor_FnTable'
--       , castPtr `Ptr VR_IVRCompositor_FnTable'
--       , `GlUInt_t'
--       , alloca- `GlSharedTextureHandle' peek* } -> `()' #}

-- TODO: virtual void LockGLSharedTextureForAccess( vr::glSharedTextureHandle_t glSharedTextureHandle ) = 0;
-- {#fun VR_IVRCompositor_FnTable->LockGLSharedTextureForAccess as ivrCompositorLockSharedTextureForAccess_
--       { coerce `VR_IVRCompositor_FnTable'
--       , castPtr `Ptr VR_IVRCompositor_FnTable'
--       , id `GlSharedTextureHandle_t' } -> `()' #}

-- TODO: virtual void UnlockGLSharedTextureForAccess( vr::glSharedTextureHandle_t glSharedTextureHandle ) = 0;
-- {#fun VR_IVRCompositor_FnTable->UnlockGLSharedTextureForAccess as ivrCompositorUnlockGLSharedTextureForAccess_
--       { coerce `VR_IVRCompositor_FnTable'
--       , castPtr `Ptr VR_IVRCompositor_FnTable'
--       , id `GlSharedTextureHandle_t' } -> `()' #}

-- virtual void SetExplicitTimingMode( bool bExplicitTimingMode ) = 0;
{#fun VR_IVRCompositor_FnTable->SetExplicitTimingMode as ivrCompositorSetExplicitTimingMode_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'
      , `Bool' } -> `()' #}

-- virtual EVRCompositorError SubmitExplicitTimingData() = 0;
{#fun VR_IVRCompositor_FnTable->SubmitExplicitTimingData as ivrCompositorSubmitExplicitTimingData_
      { coerce `VR_IVRCompositor_FnTable'
      , castPtr `Ptr VR_IVRCompositor_FnTable'} -> `EVRCompositorError' #}

-- IVRSystem
--virtual void GetRecommendedRenderTargetSize( uint32_t *pnWidth, uint32_t *pnHeight ) = 0;
{#fun VR_IVRSystem_FnTable->GetRecommendedRenderTargetSize as ivrSystemGetRecommendedRenderTargetSize_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , alloca- `CUInt' peek*
      , alloca- `CUInt' peek* } -> `()'#}

--virtual HmdMatrix44_t GetProjectionMatrix( EVREye eEye, float fNearZ, float fFarZ ) = 0;
{#fun VR_IVRSystem_GetProjectionMatrix as ivrSystemGetProjectionMatrix_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `EVREye'
      , `Float'
      , `Float'
      , alloca- `M44 Float' peek* } -> `()' #}

--TODO: virtual void GetProjectionRaw( EVREye eEye, float *pfLeft, float *pfRight, float *pfTop, float *pfBottom ) = 0;
--TODO: virtual bool ComputeDistortion( EVREye eEye, float fU, float fV, DistortionCoordinates_t *pDistortionCoordinates ) = 0;

-- virtual HmdMatrix34_t GetEyeToHeadTransform( EVREye eEye ) = 0;
{#fun VR_IVRSystem_GetEyeToHeadTransform as ivrSystemGetEyeToHeadTransform_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `EVREye'
      , alloca- `M34 Float' peek* } -> `()' #}

--TODO: virtual bool GetTimeSinceLastVsync( float *pfSecondsSinceLastVsync, uint64_t *pulFrameCounter ) = 0;
--TODO: virtual void GetOutputDevice( uint64_t *pnDevice, ETextureType textureType, VkInstance_T *pInstance = nullptr ) = 0;
{#fun VR_IVRSystem_FnTable->GetOutputDevice as ivrSystemGetOutputDevice_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , alloca- `CULong' peek*
      , `ETextureType'
      , id `Ptr ()'} -> `()'#}

-- virtual bool IsDisplayOnDesktop() = 0;
{#fun VR_IVRSystem_FnTable->IsDisplayOnDesktop as ivrSystemIsDisplayOnDesktop_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `Bool'#}

-- virtual bool SetDisplayVisibility( bool bIsVisibleOnDesktop ) = 0;
{#fun VR_IVRSystem_FnTable->SetDisplayVisibility as ivrSystemSetDisplayVisibility_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `Bool'} -> `Bool'#}

--TODO: virtual void GetDeviceToAbsoluteTrackingPose( ETrackingUniverseOrigin eOrigin, float fPredictedSecondsToPhotonsFromNow, VR_ARRAY_COUNT(unTrackedDevicePoseArrayCount) TrackedDevicePose_t *pTrackedDevicePoseArray, uint32_t unTrackedDevicePoseArrayCount ) = 0;

-- virtual void ResetSeatedZeroPose() = 0;
{#fun VR_IVRSystem_FnTable->ResetSeatedZeroPose as ivrSystemResetSeatedZeroPose_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `()'#}

--TODO: virtual HmdMatrix34_t GetSeatedZeroPoseToStandingAbsoluteTrackingPose() = 0;
--TODO: virtual HmdMatrix34_t GetRawZeroPoseToStandingAbsoluteTrackingPose() = 0;

--TODO: virtual uint32_t GetSortedTrackedDeviceIndicesOfClass( ETrackedDeviceClass eTrackedDeviceClass, VR_ARRAY_COUNT(unTrackedDeviceIndexArrayCount) vr::TrackedDeviceIndex_t *punTrackedDeviceIndexArray, uint32_t unTrackedDeviceIndexArrayCount, vr::TrackedDeviceIndex_t unRelativeToTrackedDeviceIndex = k_unTrackedDeviceIndex_Hmd ) = 0;

-- virtual EDeviceActivityLevel GetTrackedDeviceActivityLevel( vr::TrackedDeviceIndex_t unDeviceId ) = 0;
{#fun VR_IVRSystem_FnTable->GetTrackedDeviceActivityLevel as ivrSystemGetTrackedDeviceActivityLevel_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'} -> `EDeviceActivityLevel'#}

--TODO: virtual void ApplyTransform( TrackedDevicePose_t *pOutputPose, const TrackedDevicePose_t *pTrackedDevicePose, const HmdMatrix34_t *pTransform ) = 0;
-- {#fun VR_IVRSystem_FnTable->ApplyTransform as ivrSystemApplyTransform_
--       { coerce `VR_IVRSystem_FnTable'
--       , castPtr `Ptr VR_IVRSystem_FnTable'
--       , `TrackedDevicePose'
--       , `TrackedDevicePose'
--       , `M34 Float'} -> `()'#}

-- virtual vr::TrackedDeviceIndex_t GetTrackedDeviceIndexForControllerRole( vr::ETrackedControllerRole unDeviceType ) = 0;
{#fun VR_IVRSystem_FnTable->GetTrackedDeviceIndexForControllerRole as ivrSystemGetTrackedDeviceIndexForControllerRole_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `ETrackedControllerRole'} -> `TrackedDeviceIndex'#}

-- virtual vr::ETrackedControllerRole GetControllerRoleForTrackedDeviceIndex( vr::TrackedDeviceIndex_t unDeviceIndex ) = 0;
{#fun VR_IVRSystem_FnTable->GetControllerRoleForTrackedDeviceIndex as ivrSystemGetControllerRoleForTrackedDeviceIndex_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'} -> `ETrackedControllerRole'#}

-- virtual ETrackedDeviceClass GetTrackedDeviceClass( vr::TrackedDeviceIndex_t unDeviceIndex ) = 0;
{#fun VR_IVRSystem_FnTable->GetTrackedDeviceClass as ivrSystemGetTrackedDeviceClass_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'} -> `ETrackedDeviceClass'#}

-- virtual bool IsTrackedDeviceConnected( vr::TrackedDeviceIndex_t unDeviceIndex ) = 0;
{#fun VR_IVRSystem_FnTable->IsTrackedDeviceConnected as ivrSystemIsTrackedDeviceConnected_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'} -> `Bool'#}


--TODO: virtual bool GetBoolTrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, ETrackedPropertyError *pError = 0L ) = 0;
--TODO: virtual float GetFloatTrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, ETrackedPropertyError *pError = 0L ) = 0;
--TODO: virtual int32_t GetInt32TrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, ETrackedPropertyError *pError = 0L ) = 0;
--TODO: virtual uint64_t GetUint64TrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, ETrackedPropertyError *pError = 0L ) = 0;

--TODO: virtual HmdMatrix34_t GetMatrix34TrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, ETrackedPropertyError *pError = 0L ) = 0;

-- virtual uint32_t GetStringTrackedDeviceProperty( vr::TrackedDeviceIndex_t unDeviceIndex, ETrackedDeviceProperty prop, VR_OUT_STRING() char *pchValue, uint32_t unBufferSize, ETrackedPropertyError *pError = 0L ) = 0;
{#fun VR_IVRSystem_FnTable->GetStringTrackedDeviceProperty as ivrSystemGetStringTrackedDeviceProperty_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'
      , `ETrackedDeviceProperty'
      , id `Ptr CChar'
      , `Int'
      , alloca- `ETrackedPropertyError' peekEnum* } -> `Int' #}

-- virtual const char *GetPropErrorNameFromEnum( ETrackedPropertyError error ) = 0;
{#fun VR_IVRSystem_FnTable->GetPropErrorNameFromEnum as ivrSystemGetPropErrorNameFromEnum_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `ETrackedPropertyError'} -> `String' #}

-- virtual bool PollNextEvent( VREvent_t *pEvent, uint32_t uncbVREvent ) = 0;
-- i'm sure there's a better way to pass sizeof of a struct
{#fun VR_IVRSystem_FnTable->PollNextEvent as ivrSystemPollNextEvent_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `VREventPtr' -- we cannot peek this if this returns False
      , `Int' } -> `Bool' #}

--TODO: virtual bool PollNextEventWithPose( ETrackingUniverseOrigin eOrigin, VREvent_t *pEvent, uint32_t uncbVREvent, vr::TrackedDevicePose_t *pTrackedDevicePose ) = 0;

-- virtual const char *GetEventTypeNameFromEnum( EVREventType eType ) = 0;
{#fun VR_IVRSystem_FnTable->GetEventTypeNameFromEnum as ivrSystemGetEventTypeNameFromEnum_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `EVREventType'} -> `String' #}

--TODO: virtual HiddenAreaMesh_t GetHiddenAreaMesh( EVREye eEye, EHiddenAreaMeshType type = k_eHiddenAreaMesh_Standard ) = 0;
--TODO: virtual bool GetControllerState( vr::TrackedDeviceIndex_t unControllerDeviceIndex, vr::VRControllerState_t *pControllerState, uint32_t unControllerStateSize ) = 0;
--TODO: virtual bool GetControllerStateWithPose( ETrackingUniverseOrigin eOrigin, vr::TrackedDeviceIndex_t unControllerDeviceIndex, vr::VRControllerState_t *pControllerState, uint32_t unControllerStateSize, TrackedDevicePose_t *pTrackedDevicePose ) = 0;

-- virtual void TriggerHapticPulse( vr::TrackedDeviceIndex_t unControllerDeviceIndex, uint32_t unAxisId, unsigned short usDurationMicroSec ) = 0;
{#fun VR_IVRSystem_FnTable->TriggerHapticPulse as ivrSystemTriggerHapticPulse_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'
      , `CUInt'
      , `CUShort'} -> `()' #}

-- virtual const char *GetButtonIdNameFromEnum( EVRButtonId eButtonId ) = 0;
{#fun VR_IVRSystem_FnTable->GetButtonIdNameFromEnum as ivrSystemGetButtonIdNameFromEnum_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `EVRButtonId'} -> `String' #}

-- virtual const char *GetControllerAxisTypeNameFromEnum( EVRControllerAxisType eAxisType ) = 0;
{#fun VR_IVRSystem_FnTable->GetControllerAxisTypeNameFromEnum as ivrSystemGetControllerAxisTypeNameFromEnum_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `EVRControllerAxisType'} -> `String' #}

-- virtual bool CaptureInputFocus() = 0;
{#fun VR_IVRSystem_FnTable->CaptureInputFocus as ivrSystemCaptureInputFocus_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `Bool' #}

-- virtual void ReleaseInputFocus() = 0;
{#fun VR_IVRSystem_FnTable->ReleaseInputFocus as ivrSystemReleaseInputFocus_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `()' #}

-- virtual bool IsInputFocusCapturedByAnotherProcess() = 0;
{#fun VR_IVRSystem_FnTable->IsInputFocusCapturedByAnotherProcess as ivrSystemIsInputFocusCapturedByAnotherProcess_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `Bool' #}

-- virtual uint32_t DriverDebugRequest( vr::TrackedDeviceIndex_t unDeviceIndex, const char *pchRequest, char *pchResponseBuffer, uint32_t unResponseBufferSize ) = 0;
{#fun VR_IVRSystem_FnTable->DriverDebugRequest as ivrSystemDriverDebugRequest_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'
      , `String'
      , `String'
      , `CUInt'} -> `CUInt' #}

-- virtual vr::EVRFirmwareError PerformFirmwareUpdate( vr::TrackedDeviceIndex_t unDeviceIndex ) = 0;
{#fun VR_IVRSystem_FnTable->PerformFirmwareUpdate as ivrSystemPerformFirmwareUpdate_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'
      , `TrackedDeviceIndex'} -> `EVRFirmwareError' #}

-- virtual void AcknowledgeQuit_Exiting() = 0;
{#fun VR_IVRSystem_FnTable->AcknowledgeQuit_Exiting as ivrSystemAcknowledgeQuit_Exiting_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `()' #}

-- virtual void AcknowledgeQuit_UserPrompt() = 0;
{#fun VR_IVRSystem_FnTable->AcknowledgeQuit_UserPrompt as ivrSystemAcknowledgeQuit_UserPrompt_
      { coerce `VR_IVRSystem_FnTable'
      , castPtr `Ptr VR_IVRSystem_FnTable'} -> `()' #}

-- IVRRenderModels

-- handle freeing gracefully

--virtual EVRRenderModelError LoadRenderModel_Async( const char *pchRenderModelName, RenderModel_t **ppRenderModel ) = 0;
{#fun VR_IVRRenderModels_FnTable->LoadRenderModel_Async as ivrRenderModelsLoadRenderModel_Async_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `String'
      , alloca- `RenderModelPtr' peek* } -> `EVRRenderModelError' #}
--virtual void FreeRenderModel( RenderModel_t *pRenderModel ) = 0;
{#fun VR_IVRRenderModels_FnTable->FreeRenderModel as ivrRenderModelsFreeRenderModel_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `RenderModelPtr' } -> `()' #}
--virtual EVRRenderModelError LoadTexture_Async( TextureID_t textureId, RenderModel_TextureMap_t **ppTexture ) = 0;
{#fun VR_IVRRenderModels_FnTable->LoadTexture_Async as ivrRenderModelsLoadTexture_Async_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `TextureID'
      , alloca- `RenderModel_TextureMapPtr' peek* } -> `EVRRenderModelError' #}
--virtual void FreeTexture( RenderModel_TextureMap_t *pTexture ) = 0;
{#fun VR_IVRRenderModels_FnTable->FreeTexture as ivrRenderModelsFreeTexture_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `RenderModel_TextureMapPtr' } -> `()' #}

--TODO: virtual uint32_t GetRenderModelName( uint32_t unRenderModelIndex, VR_OUT_STRING() char *pchRenderModelName, uint32_t unRenderModelNameLen ) = 0;
-- virtual uint32_t GetRenderModelCount() = 0;
{#fun VR_IVRRenderModels_FnTable->GetRenderModelCount as ivrRenderModelsGetRenderModelCount_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'} -> `CUInt' #}
-- virtual uint32_t GetComponentCount( const char *pchRenderModelName ) = 0;
{#fun VR_IVRRenderModels_FnTable->GetComponentCount as ivrRenderModelsGetComponentCount_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `String'} -> `CUInt' #}
--TODO: virtual uint32_t GetComponentName( const char *pchRenderModelName, uint32_t unComponentIndex, VR_OUT_STRING( ) char *pchComponentName, uint32_t unComponentNameLen ) = 0;
--TODO: virtual uint64_t GetComponentButtonMask( const char *pchRenderModelName, const char *pchComponentName ) = 0;
--TODO: virtual uint32_t GetComponentRenderModelName( const char *pchRenderModelName, const char *pchComponentName, VR_OUT_STRING( ) char *pchComponentRenderModelName, uint32_t unComponentRenderModelNameLen ) = 0;
--TODO: virtual bool GetComponentState( const char *pchRenderModelName, const char *pchComponentName, const vr::VRControllerState_t *pControllerState, const RenderModel_ControllerMode_State_t *pState, RenderModel_ComponentState_t *pComponentState ) = 0;

-- virtual bool RenderModelHasComponent( const char *pchRenderModelName, const char *pchComponentName ) = 0;
{#fun VR_IVRRenderModels_FnTable->RenderModelHasComponent as ivrRenderModelsRenderModelHasComponent_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `String'
      , `String'} -> `Bool' #}

--TODO: virtual uint32_t GetRenderModelThumbnailURL( const char *pchRenderModelName, VR_OUT_STRING() char *pchThumbnailURL, uint32_t unThumbnailURLLen, vr::EVRRenderModelError *peError ) = 0;
--TODO: virtual uint32_t GetRenderModelOriginalPath( const char *pchRenderModelName, VR_OUT_STRING() char *pchOriginalPath, uint32_t unOriginalPathLen, vr::EVRRenderModelError *peError ) = 0;

-- virtual const char *GetRenderModelErrorNameFromEnum( vr::EVRRenderModelError error ) = 0;
{#fun VR_IVRRenderModels_FnTable->GetRenderModelErrorNameFromEnum as ivrRenderModelsGetRenderModelErrorNameFromEnum_
      { coerce `VR_IVRRenderModels_FnTable'
      , castPtr `Ptr VR_IVRRenderModels_FnTable'
      , `EVRRenderModelError'} -> `String' #}
